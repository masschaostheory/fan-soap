using xml
//using haystack

**
** SOAP Schema Object
**
const class WSDLSchema {

  const Str targetNamespace
    const WSDLSchemaObj[] reqs := [,]
  const WSDLSchemaObj[] objs := [,]

  new make(XElem schema) {
    targetNamespace = (schema.attrs.find | attr | { attr.name == "targetNamespace" }).val

    WSDLSchemaObj[] reqs := [,]
    WSDLSchemaObj[] objs := [,]

    schema.elems.each | elem | {
      switch (elem.name) {
        case "simpleType":
          objs.add(WSDLSimpleType(elem))

        case "complexType":
          objs.add(WSDLComplexType(elem))

        case "element":
          reqs.add(WSDLElement(elem))

        default: throw Err("Unknown SOAP element $elem")

      }
    }

    this.reqs = reqs
    this.objs = objs
  }

  Str[] reqList() {
    Str[] list := [,]

    reqs.each | req | { list.add(req.name) }

    return list
  }

  Str[] objList() {
    Str[] list := [,]

    objs.each | obj | { list.add(obj.name) }

    return list
  }
}

** WSDL Class modeling a schema object
abstract const class WSDLSchemaObj {

  const Str? name
  const Str ns

  new make(XElem element) {
    try { this.name = (element.attrs.find | attr | { attr.name == "name" })?.val }
    catch (Err err) { throw Err("$element.parent's child has no name attribute")}
    this.ns = element.prefix
  }
}

** WSDL Class modeling a simple object
const class WSDLSimpleType : WSDLSchemaObj {

  const Str type := "simple"
  const Str restriction
  const Str[] availValues

  new make(XElem element) : super(element) {
    Str? restriction
    Obj[] avail := [,]

    element.elems.each | elem | {
      if (elem.name.equals("restriction")) {
        restriction = elem.attr("base").val
        elem.elems.each | e | {
          if (e.name.equals("enumeration")) {
            avail.add(e.attr("value").val)
          }
        }
      }
    }

    this.restriction = restriction
    this.availValues = avail
  }

}

** WSDL Class modeling a complex object
const class WSDLComplexType : WSDLSchemaObj {

  const Str type := "complex"
  const WSDLElement[]? sequence := [,]

  new make(XElem element) : super(element) {
    WSDLElement[]? sequence := [,]

    element.elems.each | elem | {
      if (elem.name.equals("sequence")) {
        elem.elems.each | e | { sequence.add(WSDLElement(e)) }
      }
    }

    this.sequence = sequence
  }

  override Str toStr() {
    XElem element := XElem("complexType")
    XElem seqChild := XElem("sequence")

    sequence.each | elem | { seqChild.add(XElem("element").addAttr("name", elem.name).addAttr("type", elem.type)) }

    element.add(seqChild)

    return element.writeToStr
  }

}

** WSDL Class modeling an element
const class WSDLElement : WSDLSchemaObj {

  const Obj type

  new make(XElem element) : super(element) {
    Obj? type := (element.attrs.find | attr | { attr.name == "type" })?.val

    if (type == null) {
      element.elems.each | elem | {
        switch (elem.name) {
          case "simpleType":
            type = WSDLSimpleType(elem)

          case "complexType":
            type = WSDLComplexType(elem)

          default: throw Err("SOAPElement $element has an invalid type $elem.name")
        }
      }
    }

    this.type = type
  }

  override Str toStr() {
    Str str := Str.defVal

    if (type is Str) str = "<element name='$name' type='$type'/>"
    else str = "\n<element name='$name'>\n" + type.toStr + "\n</$name>"

    return str
  }

}
