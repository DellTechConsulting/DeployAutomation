function Run_Automation_Script(formType) {
  //Code to fetch the path from below forms
  if (
    formType == "cr-install" ||
    formType == "cs-install" ||
    formType == "ave-install" ||
    formType == "networker-install" ||
    formType == "proxy-install" ||
    formType == "ppdm-install"
  ) {
    var pathname = document.getElementById("ovaPath-" + formType).value;
    document.getElementById("hiddenpath-" + formType).value = pathname;
  }

  if (formType == "cs-install") {
    var newadminpass = document.getElementById("newadminpass").value;
    var confirmPassword = document.getElementById("confirmPassword").value;

    if (newadminpass != confirmPassword) {
      $(".alert-cs").show();
      return false;
    }
  }

  if (formType == "ddve-install") {
    $(".alert").hide();
    var credentials_pwd = document.getElementById("credentials_pwd").value;
    var cradminuser_pwd = document.getElementById("cradminuser_pwd").value;
    var secofficer1_pwd = document.getElementById("secofficer1_pwd").value;
    var secofficer2_pwd = document.getElementById("secofficer2_pwd").value;

    if (cradminuser_pwd == credentials_pwd) {
      $(".alert1").show();
      return false;
    }

    if (secofficer1_pwd == credentials_pwd) {
      $(".alert2").show();
      return false;
    }

    if (secofficer1_pwd == cradminuser_pwd) {
      $(".alert3").show();
      return false;
    }

    if (secofficer2_pwd == credentials_pwd) {
      $(".alert4").show();
      return false;
    }

    if (secofficer2_pwd == cradminuser_pwd) {
      $(".alert5").show();
      return false;
    }

    if (secofficer2_pwd == secofficer1_pwd) {
      $(".alert6").show();
      return false;
    }
  }

  var formInput = $("#" + formType).serialize();
  //decode back serialize string to original spl characters
  var decodedForm = decodeURIComponent(formInput);

  // replace ' ' with %20
  var replaceSpace = decodedForm.replace(/\ /g, "%20");
  alert(replaceSpace)
  // Run script
  WshShell = new ActiveXObject("WScript.Shell");
  var script = "deploy.sh " + formType + " " + replaceSpace;
  WshShell.Run(script, 1, false);
}

// Reset form fields
function ResetForm(formType) {
  document.getElementById(formType).reset();
}

function runBookAutomation(formType) {
  //Code to fetch the path from below forms
  if (
    formType == "cr-form" ||
    formType == "cs-install-form" ||
    formType == "ave-install-form" ||
    formType == "networker-install-form" ||
    formType == "proxy-install-form" ||
    formType == "ppdm-install-form"
  ) {
    if(document.getElementById("hiddenpath-" + formType).value == ''){
      var pathname = document.getElementById("ovaPath-" + formType).value;
      document.getElementById("hiddenpath-" + formType).value = pathname;
    }    
  }
  if (formType == "cr-form") {
    runBookFormData("cr-form", "cs-install-form");
    runBookFormData("cr-form", "ave-install-form");
    runBookFormData("cr-form", "networker-install-form");
    runBookFormData("cr-form", "proxy-install-form");
    runBookFormData("cr-form", "ppdm-install-form");
    runBookFormData("cr-form", "ntp-install-form");
    runBookFormData("cr-form", "dns-install-form");
    if(checkButtonAttr("cr-form-btn")){
      runBookSteps("cr-form-btn");
      return false;
    }      
  }
  if (formType == "cs-install-form") {
    document.getElementById("cs-form-alert").style.display = "none";
    var newadminpass = document.querySelector(
      '#cs-install-form input[name="newadminpass"]'
    ).value;
    var confirmPassword = document.querySelector(
      '#cs-install-form input[name="confirmPassword"]'
    ).value;
    //var newadminpass = document.getElementById("newadminpass").value;
    //var confirmPassword = document.getElementById("confirmPassword").value;

    if (newadminpass != confirmPassword) {
      document.getElementById("cs-form-alert").style.display = "block";
      return false;
    }
    if(checkButtonAttr("cs-install-form-btn")){
      runBookSteps("cs-install-form-btn");
      return false;
    }    
  }

  if (formType == "ddve-install-form") {
    //$(".alert").hide();
    /*document.querySelectorAll('.ddve-install-section1 .alert').forEach(el => {
        el.style.display = "none";
    });*/

    var elements = document.querySelectorAll(
      ".ddve-install-section1 .alert"
    );
    for (var i = 0; i < elements.length; i++) {
      var el = elements[i];
      el.style.display = "none";
    }

    var credentials_pwd = document.querySelector(
      '#ddve-install-form input[id="credentials_pwd"]'
    ).value;
    var cradminuser_pwd = document.querySelector(
      '#ddve-install-form input[id="cradminuser_pwd"]'
    ).value;
    var secofficer1_pwd = document.querySelector(
      '#ddve-install-form input[id="secofficer1_pwd"]'
    ).value;
    var secofficer2_pwd = document.querySelector(
      '#ddve-install-form input[id="secofficer2_pwd"]'
    ).value;

    if (cradminuser_pwd == credentials_pwd) {
      document.querySelector(
        ".ddve-install-section1 .alert1"
      ).style.display = "block";

      return false;
    }

    if (secofficer1_pwd == credentials_pwd) {
      document.querySelector(
        ".ddve-install-section1 .alert2"
      ).style.display = "block";
      return false;
    }

    if (secofficer1_pwd == cradminuser_pwd) {
      document.querySelector(
        ".ddve-install-section1 .alert3"
      ).style.display = "block";
      return false;
    }

    if (secofficer2_pwd == credentials_pwd) {
      document.querySelector(
        ".ddve-install-section1 .alert4"
      ).style.display = "block";
      return false;
    }

    if (secofficer2_pwd == cradminuser_pwd) {
      document.querySelector(
        ".ddve-install-section1 .alert5"
      ).style.display = "block";
      return false;
    }

    if (secofficer2_pwd == secofficer1_pwd) {
      document.querySelector(
        ".ddve-install-section1 .alert6"
      ).style.display = "block";
      return false;
    }

    if(checkButtonAttr("ddve-install-form-btn")){
      runBookSteps("ddve-install-form-btn");
      return false;
    }  
    
  }

  if (formType == "ave-install-form" && checkButtonAttr("ave-install-form-btn")) {
    runBookSteps("ave-install-form-btn");
    return false;
  }

  if (formType == "networker-install-form" && checkButtonAttr("networker-install-form-btn")) {
    runBookSteps("networker-install-form-btn");
    return false;
  }

  if (formType == "proxy-install-form" && checkButtonAttr("proxy-install-form-btn")) {
    runBookSteps("proxy-install-form-btn");
    return false;
  }

  if (formType == "ppdm-install-form" && checkButtonAttr("ppdm-install-form-btn")) {
    runBookSteps("ppdm-install-form-btn");
    return false;
  }
  if (formType == "ntp-install-form" && checkButtonAttr("ntp-install-form-btn")) {
    runBookSteps("ntp-install-form-btn");
    return false;
  }
  
  runWinShell("cr-form", "cr-install");
  runWinShell("cs-install-form", "cs-install");
  runWinShell("ave-install-form", "ave-install");
  runWinShell("networker-install-form", "networker-install");
  runWinShell("proxy-install-form", "proxy-install");
  runWinShell("ppdm-install-form", "ppdm-install");
  runWinShell("ntp-install-form", "ntp-install");
  runWinShell("dns-install-form", "dns-install");
  //finalStep()
  return false;
}


function runWinShell(formType, shFile){
  var is_skip = parseInt($("#" + formType).attr('is-skip'))
  
  if(is_skip!=1){
    //console.log($("#" + formType))
    var formInput = $("#" + formType).serialize();
    console.log(formInput)
    //var randomString1 = randomString(10)+".txt";
    //document.getElementById(formType+"-random").value = randomString1;
    formInput = formInput;
    //decode back serialize string to original spl characters
    var decodedForm = decodeURIComponent(formInput);
    // replace ' ' with %20
    var replaceSpace = decodedForm.replace(/\ /g, "%20");
    alert(replaceSpace)
    // Run script
    WshShell = new ActiveXObject("WScript.Shell"); 
    //shFile = shFile+"-wizard"
    var script = "deploy.sh " + shFile + " " + replaceSpace;
    WshShell.Run(script, 1, false);  
  }  
}


function finalStep(){
  var formStepElements = document.querySelectorAll(".form-step");
  for (var i = 0; i < formStepElements.length; i++) {
      formStepElements[i].classList.add("d-none");
  }

  document.querySelector("#final-step").classList.remove("d-none");

  var formStepElements1 = document.querySelectorAll("section");
  console.log(formStepElements1)
  var htmlContent = ''
  for (var i = 0; i < formStepElements1.length; i++) {
    if(formStepElements1[i].getAttribute('id') != 'step-1' && formStepElements1[i].getAttribute('is-modified') == "0"){
      htmlContent +=  '<div class="col-md-12">'+
                        '<div class="input-group mb-3">'+
                            '<div class="loader">'+
                                '<div class="loader-inner"></div>'+
                            '</div>'+

                            '<div class="status success" style="display: none;">'+
                                '<i class="bi bi-check-circle-fill"></i>'+
                            '</div>'+

                            '<div class="status error" style="display: none;">'+
                                '<i class="bi bi-x-circle"></i>'+
                            '</div>'+

                            '<span class="input-group-text" for="vCenter">'+formStepElements1[i].getAttribute('section-text')+'</span>'+
                            
                            
                        '</div>'+
                    '</div>';
    }  

    document.getElementById("final-steps-wizards").innerHTML = htmlContent
    
  }
}

function checkButtonAttr(btn){
  if(document.getElementById(btn).hasAttribute("step")){
    return true
  }else{
    return false;
  } 
}

function randomString(length) {
  var chars="0123456789abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ"
  var result = '';
  for (var i = length; i > 0; --i) result += chars[Math.floor(Math.random() * chars.length)];
  return result;
}

function runBookSteps(btn) {
  const stepNumber = parseInt(
    document.getElementById(btn).getAttribute("step")
  );
  navigateToFormStep(stepNumber);
}

function objectifyForm(formArray) {
  //serialize data function
  var returnArray = {};
  for (var i = 0; i < formArray.length; i++){
      returnArray[formArray[i]['name']] = formArray[i]['value'];
  }
  return returnArray;
}

function runBookFormData(form, destinationForm) {
  var formInput = $("#" + form).serializeArray();
  formInput = objectifyForm(formInput);
  //console.log("formInput::", formInput)
  const inputs = document
    .querySelector("#" + destinationForm)
    .getElementsByTagName("input");

  for (var i = 0; i < inputs.length; i++) {
    if ((inputs[i].name!='VMName' && inputs[i].name!='fqdn') && formInput[inputs[i].name]) {
      inputs[i].value = formInput[inputs[i].name];
    }
    if (destinationForm == "cs-install-form") {
      // if (inputs[i].name == "ip_cs")
      //   inputs[i].value = formInput["ip_cr"];
      if (inputs[i].name.toLowerCase() == "network0")
        inputs[i].value = formInput["Network"];
      if (inputs[i].name.toLowerCase() == "netmask0")
        inputs[i].value = formInput["netmask"];
    }
    if (destinationForm == "ntp-install-form") {
      //if (inputs[i].name == "server")
        //inputs[i].value = formInput["ip_cr"];
      if (inputs[i].name == "ntpName")
        inputs[i].value = formInput["NTP"];
    }
    // if (destinationForm == "dns-install-form") {
    //   if (inputs[i].name == "server")
    //     inputs[i].value = formInput["ip_cr"];
    // }
  }
  /*var formData = new FormData(document.getElementById(form));

  // iterate through entries...
  // ...or output as an object
  //var sourceFormData = Object.fromEntries(formData);
  var sourceFormData = {};
  console.log("SourceFormData::", sourceFormData)
  const inputs = document
    .querySelector("#" + destinationForm)
    .getElementsByTagName("input");
  var pair;

  console.log("formData::", formData.entries());

  //for (pair of formData.entries()) {
  var entries = formData.entries();

  for (var pair = entries.next(); !pair.done; pair = entries.next()) {
    var key = pair.value[0];
    console.log("key::", key)
    
    var value = pair.value[1];
    console.log("value::",value)
    for (var i = 0; i < inputs.length; i++) {
      if (key.toLowerCase() == inputs[i].name.toLowerCase()) {
        inputs[i].value = value;
      }
      if (destinationForm == "cs-install-form") {
        if (inputs[i].name == "ip_cs")
          inputs[i].value = sourceFormData["ip_cr"];
        if (inputs[i].name.toLowerCase() == "network0")
          inputs[i].value = sourceFormData["Network"];
        if (inputs[i].name.toLowerCase() == "netmask0")
          inputs[i].value = sourceFormData["netmask"];
      }
      if (destinationForm == "ntp-install-form") {
        if (inputs[i].name == "server")
          inputs[i].value = sourceFormData["ip_cr"];
        if (inputs[i].name == "ntpName")
          inputs[i].value = sourceFormData["NTP"];
      }
      if (destinationForm == "dns-install-form") {
        if (inputs[i].name == "server")
          inputs[i].value = sourceFormData["ip_cr"];
      }
    }
  }*/

  /*for (const [key, value] of Object.fromEntries(formData)) {
        for (var i = 0; i < inputs.length; i++) {
	    console.log(key)
	    console.log(input[i].name)
            if (inputs[i].type.toLowerCase() === "password" || inputs[i].type.toLowerCase() === "text") {
                inputs[i].value = "test" + i
            }
            if (inputs[i].type.toLowerCase() == "file") {
                console.log(inputs[i].files)
            }
        }
    }*/
}

