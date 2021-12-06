#! /usr/bin/env fan

using build

class Build : build::BuildPod
{
  new make()
  {
    podName = "soap"
    summary = "Description of this pod"
    version = Version("0.9.0") //BETA
    meta = [
            "proj.name":    "SOAP-Fan",
            "proj.uri":     "https://github.com/abible-intellastar/soap-fan/",
            "license.name": "MIT",
            "vcs.name":     "Git",
            "vcs.uri":      "https://github.com/abible-intellastar/soap-fan/"
    ]
    depends = [
                "sys 1.0",
                "web 1.0",
                "xml 1.0",
                "dom 1.0",
              ]
    srcDirs = [`fan/`, `fan/wsdl/`, `test/`]
  }
}

