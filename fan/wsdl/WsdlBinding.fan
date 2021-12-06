using xml
//using haystack

const class WSDLBinding : WSDLSchemaObj {

  const [Str:SOAPOperation] opsMap

//  const Str name
  const Str type
  const Str transport
//  const Str style

  new make(XElem element) : super(element) {
//    this.name = element.attr("name").val
    this.type = element.attr("type").val

    [Str:SOAPOperation] opsMap := [:]
    Str transport := Str.defVal
    //Str style := Str.defVal

    element.elems.each | elem | {
      switch (elem.name) {
        case "binding":
          //style = elem.attr("style").val
          transport = elem.attr("transport").val

        case "operation":
          opsMap.add(elem.attr("name").val, SOAPOperation(elem))

        default:

      }
    }

    this.opsMap = opsMap
    this.transport = transport
    //this.style = style
  }
}

** SOAP Class to model a WSDL operation, this is mainly used for binding
const class SOAPOperation : WSDLSchemaObj {
  const Uri soapAction
  const SOAPHeader? header
  const SOAPBody? inputBody
  const SOAPBody? outputBody

  new make(XElem element) : super(element) {
    Uri soapAction := Uri.defVal
    SOAPHeader? header
    SOAPBody? inputBody
    SOAPBody? outputBody

    element.elems.each | elem | {
      switch (elem.name) {
        case "operation":
          soapAction = Uri(elem.attr("soapAction").val)
        case "input":
          elem.elems.each | e | {
            if (e.name == "header") header = SOAPHeader(e)
            else if (e.name == "body")  inputBody = SOAPBody(e)
            else throw Err("Unknown element $e in SOAPOperation input")
          }
        case "output":
          elem.elems.each | e | {
            if (e.name == "body") outputBody = SOAPBody(e)
            else throw Err("Unknown element $e in SOAPOperation output")
          }
        default:
      }
    }

    this.soapAction = soapAction
    this.header = header
    this.inputBody = inputBody
    this.outputBody = outputBody
  }
}

** SOAP Class to model a SOAPRequest header
const class SOAPHeader {
  const Str message
  const Str part
  const Str use

  new make(XElem? element) {
    this.message = element.attr("message").val
    this.part = element.attr("part").val
    this.use = element.attr("use").val
  }
}

** SOAP Class to model a SOAPRequest body
const class SOAPBody {
  const Str use

  new make(XElem element) {
    this.use = element.attr("use").val
  }
}