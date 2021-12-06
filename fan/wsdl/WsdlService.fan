using xml

const class WSDLService : WSDLSchemaObj {

  const WSDLPort port

  new make(XElem element) : super(element) {
    WSDLPort? port

    element.elems.each | elem | {
      switch (elem.name) {
        case "port":
          port = WSDLPort(elem)

        default:

      }
    }

    this.port = port
  }

}

** WSDL Class for modeling the SOAP service port
const class WSDLPort : WSDLSchemaObj {

  const Str binding := Str.defVal
  const Str doc := Str.defVal
  const Uri uri := Uri.defVal

  new make(XElem element) : super(element) {
    this.binding = element.attr("binding").val

    Str doc := Str.defVal
    Uri uri := Uri.defVal

    element.elems.each | elem | {
      switch (elem.name) {
        case "documentation":
          doc = elem.text.val

        case "address":
          uri = Uri(elem.attr("location").val)

        default:
          throw Err("Unknown element $elem in WSDLPort")
      }
    }

    this.doc = doc
    this.uri = uri
  }
}