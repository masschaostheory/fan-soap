using xml
//using haystack

const class WSDLMessage : WSDLSchemaObj {

//  const Str name
  const Str element

  new make(XElem elem) : super(elem) {
//    this.name = elem.attr("name").val
    element := "no_element"

    elem.elems.each | e | {
      if (e.name.equals("part")) {
        element = e.attr("element").val
      }
    }

    this.element = element
  }

}
