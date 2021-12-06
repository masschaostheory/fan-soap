// History:
//  Nov 28 20 root Creation
//

using web
using xml

**
** SoapTest
**
class SoapTest : Test
{
  Uri testWsdl := `http://www.dneonline.com/calculator.asmx?wsdl`

  WSDL? wsdl
  SOAPEnvelope? env

  override Void setup() {
    echo("Fetching test wsdl...")
    echo(testWsdl)
    echo("--------------------")
    echo(WebClient(testWsdl).getIn.readAllStr)
    echo("--------------------")
    wsdl := WSDL(testWsdl)
    echo("Creating SOAP Envelope...")
    this.env = SOAPEnvelope(wsdl)
    echo("Setup complete!")
  }

  Void testSoapService() {
    req  := env.createRequest("Subtract")
    echo
    echo("====================")
    echo("Create Request: $req.soapAction")
    echo("Fields:")
    echo(req.fields)
    echo("Variables:")
    vars := ["intA":10, "intB":7]
    req1 := env.createRequest("Subtract", vars)
    req1.send
    echo("SOAP Response")
    req1.soapResponse.write(Env.cur.out)
    echo
  }

  override Void teardown() {}

}