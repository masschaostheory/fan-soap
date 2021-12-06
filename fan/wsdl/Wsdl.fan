using xml
using web
//using haystack

**
** Class modeling a Wsb Service Description Locator
**
const class WSDL {

  const Uri uri

  const [Str:Str] nsMap
  const [Str:Str] attributes

  const WSDLSchema? schema

  const WSDLMessage[] messages

  const WSDLPortType portType

  const WSDLBinding binding

  const WSDLService service

  new make(Uri? uri := null) {
    this.uri = uri

    File? file
    WebClient? client

    try { file = File(uri) }
    catch (Err e) { client = WebClient(uri) }
    finally { if (client == null && file == null) throw Err("Invalid WSDL uri") }

    [Str:Str] nsMap := [:]
    [Str:Str] attributes := [:]

    WSDLMessage[] messages := [,]
    WSDLPortType? portType
    WSDLBinding? binding
    WSDLService? service

    XDoc? doc

    if (client == null) doc = XParser(file.open.in).parseDoc(true)
    if (file == null) doc = XParser(client.getIn).parseDoc(true)

    doc.root.attrs.each | attr | {
      if (attr.name.contains("xmlns")) nsMap.add(attr.name.split(':')[1], attr.val)
      else attributes.add(attr.name, attr.val)
    }

    this.nsMap = nsMap
    this.attributes = attributes

    doc.root.elems.each | elem | {
      switch (elem.name) {
        case "types":
          schema = WSDLSchema(elem.elem("schema"))

        case "message":
          messages.add(WSDLMessage(elem))

        case "portType":
          portType = WSDLPortType(elem)

        case "binding":
          binding = WSDLBinding(elem)

        case "service":
          service = WSDLService(elem)

        default: throw Err("Unknown SOAP element $elem")

      }
    }

    this.messages = messages
    this.portType = portType
    this.binding = binding
    this.service = service
  }
}