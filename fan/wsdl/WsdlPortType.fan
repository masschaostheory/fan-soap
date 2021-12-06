using xml
//using haystack

const class WSDLPortType : WSDLSchemaObj {

  const WSDLOperation[] operations

  new make(XElem element) : super(element) {
    WSDLOperation[] operations := [,]

    element.elems.each | elem | {
      operations.add(WSDLOperation(elem))
    }

    this.operations = operations
  }

}

** SOAP Operation class
const class WSDLOperation : WSDLSchemaObj {

  const Str doc
  const Str inputMessage
  const Str outputMessage

  new make(XElem element) : super(element) {
    Str doc := Str.defVal
    Str inputMessage := Str.defVal
    Str outputMessage := Str.defVal

    element.elems.each | elem | {
      switch (elem.name) {
        case "documentation":
          doc = elem.text.val

        case "input":
          inputMessage = elem.attr("message").val

        case "output":
          outputMessage = elem.attr("message").val

        default: throw Err("Unknown SOAPOperation element $elem")

      }
    }

    this.doc = doc
    this.inputMessage = inputMessage
    this.outputMessage = outputMessage
  }

}
