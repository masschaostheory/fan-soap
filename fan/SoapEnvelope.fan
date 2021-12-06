using xml
using web

class SOAPEnvelope {

  // WSDL
  const WSDL wsdl

  XDoc? soapResponse

  // SOAP Request Variables
  XElem? soapRequest
  SOAPElement[] reqElements := [,]
  XElem? header
  XElem? body

  // SOAP Environment and Namespace vars
  XNs soapenv := XNs("soapenv", `http://schemas.xmlsoap.org/soap/envelope/`)
  XNs ns

  Uri? targetUri
  Str? soapAction

  new make(WSDL wsdl) {
    this.wsdl = wsdl
    this.ns = XNs("tns", Uri(wsdl.schema.targetNamespace))

    _init
  }

  Void _init() {
    this.header = XElem("Header", soapenv)
    this.body = XElem("Body", soapenv)

    this.soapRequest = XElem("Envelope", soapenv)
    this.soapRequest.addAttr("xmlns:soapenv", "http://schemas.xmlsoap.org/soap/envelope/")
    this.soapRequest.addAttr("xmlns:tns", wsdl.schema.targetNamespace)
    this.targetUri = wsdl.uri
    this.soapResponse = XDoc()
//    echo("Init SoapRequest: $this.soapResponse.toStr")
  }

  Void send() {
    // Sanity Check
    if (this.targetUri == null) throw ArgErr("No target URI available")
//    echo(targetUri)

    // Define Client
    WebClient client := WebClient(this.targetUri)

    // Define Headers
    client.reqHeaders.add("SOAPAction", this.soapAction)

    // Define Response Content Type
    client.reqHeaders.add("Content-Type", "text/xml;charset=UTF-8")

    // POST Request
    client.postStr(this.soapRequest.writeToStr)
//    echo
//    echo(client.reqHeaders)
//    this.soapRequest.write(Env.cur.out)
//    echo

    // Get the response
    this.soapResponse = XParser(client.resIn).parseDoc(true)
    //echo(client.resIn.readAllLines)

   // DEBUG
//    echo(client.resCode)
    //echo(client.resIn.readAllStr)
//    echo(soapResponse.writeToStr)

  }

  This createRequest(Str op, [Str:Obj]? vals := null) {
    _init

    //This needs to be sanity checked!
    operation := wsdl.portType.operations.find | oper | { oper.name == op }
    binding   := wsdl.binding.opsMap[operation.name]

    this.soapAction = binding.soapAction.toStr
//    echo("SoapAction: $this.soapAction")
    reqMsgName := operation.inputMessage.split(':').last
    resMsgName := operation.outputMessage.split(':').last
    reqBody := XElem(operation.name, ns)
//    echo
    this.reqElements = getElements(reqMsgName)

    reqElements.each | element | {
      Obj? elementVal

      if (vals != null) {
        elementVal = vals.find | val, key | { key == element.name }
        element.setVal(elementVal)
      }
      //element.write(Env.cur.out)
      reqBody = reqBody.add(element)
    }

    reqBody.write(Env.cur.out)
//    echo

    //Assemble body
    body.add(reqBody)

    //Assemble envelope
    soapRequest.add(header).add(body)

    return this
  }

  Str[] fields() {
    list := [,]
    reqElements.each | element | { list.add(element.name)  }

    return list
  }

  private SOAPElement[] getElements(Str msgName) {
    SOAPElement[] elements := [,]
    message := wsdl.messages.find | msg | { msg.name == msgName }
    req := wsdl.schema.reqs.find | req | { req.name == message.element.split(':').last }

    if ((req is WSDLElement) && (req as WSDLElement).type is WSDLComplexType) {
      ((req as WSDLElement).type as WSDLComplexType).sequence.each | element | {
        elements.add(SOAPElement(this.ns, element.name, element.type))
      }
    }

    return elements
  }

}

class SOAPElement : XElem {

  const Type type
  Obj? val

  const Bool isEnum

  const Str[] enumAvail

  new make(XNs ns, Str name, Obj typeObj) : super(this.name, ns) {
    this.name = name

    Bool isEnum := false
    Str[] enumAvail := [,]
    Type? type

    if (typeObj is Str) {
      switch (typeObj) {
        case "s:int":
          type = Int#
        case "s:dateTime":
          type = DateTime#
        default:
          type = Str#
      }
    }
    else if (typeObj is WSDLSimpleType) {
      switch ((typeObj as WSDLSimpleType).restriction) {
        case "s:string":
          type = Str#
          isEnum = true
          enumAvail = (typeObj as WSDLSimpleType).availValues
        default:
      }
    }

    this.isEnum = isEnum
    this.enumAvail = enumAvail
    this.type = type
  }

  This setVal(Obj? val) {
    add(XText(val.toStr))
    // TODO Type validation
//    if (val.typeof != type) {
//      throw ArgErr("Invalid SOAP Element value $val of type $val.typeof Expecting $type")
//    }

    // TODO Enumeration Check

    // TODO Validate value

    return this
  }

}