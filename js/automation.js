function Run_Automation_Script(formType) {
  //Code to fetch the path from below forms
  if (
    formType == "cr-install" ||
    formType == "cs-install" ||
    formType == "ave-install" ||
    formType == "networker-install" ||
    formType == "proxy-install" ||
    formType == "ppdm-install" ||
    formType == "networker-proxy-install"
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
    formType == "ppdm-install-form" || 
    formType == "networker-proxy-install-form"
  ) {
    //if(document.getElementById("hiddenpath-" + formType).value == '')
    {
      var pathname = document.getElementById("ovaPath-" + formType).value;
      document.getElementById("hiddenpath-" + formType).value = pathname;
    }
  }
  if (formType == "cr-form") {
    runBookFormData("cr-form", "cs-install-form");
    runBookFormData("cr-form", "ave-install-form");
    runBookFormData("cr-form", "networker-install-form");
    runBookFormData("cr-form", "networker-proxy-install-form");
    runBookFormData("cr-form", "proxy-install-form");
    runBookFormData("cr-form", "ppdm-install-form");
    runBookFormData("cr-form", "ntp-install-form");
    runBookFormData("cr-form", "dns-install-form");
    if (checkButtonAttr("cr-form-btn")) {
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
    if (checkButtonAttr("cs-install-form-btn")) {
      runBookSteps("cs-install-form-btn");
      return false;
    }
  }

  if (formType == "ddve-install-form") {
    //$(".alert").hide();
    /*document.querySelectorAll('.ddve-install-section1 .alert').forEach(el => {
        el.style.display = "none";
    });*/

    var elements = document.querySelectorAll(".ddve-install-section1 .alert");
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
      document.querySelector(".ddve-install-section1 .alert1").style.display =
        "block";

      return false;
    }

    if (secofficer1_pwd == credentials_pwd) {
      document.querySelector(".ddve-install-section1 .alert2").style.display =
        "block";
      return false;
    }

    if (secofficer1_pwd == cradminuser_pwd) {
      document.querySelector(".ddve-install-section1 .alert3").style.display =
        "block";
      return false;
    }

    if (secofficer2_pwd == credentials_pwd) {
      document.querySelector(".ddve-install-section1 .alert4").style.display =
        "block";
      return false;
    }

    if (secofficer2_pwd == cradminuser_pwd) {
      document.querySelector(".ddve-install-section1 .alert5").style.display =
        "block";
      return false;
    }

    if (secofficer2_pwd == secofficer1_pwd) {
      document.querySelector(".ddve-install-section1 .alert6").style.display =
        "block";
      return false;
    }

    if (checkButtonAttr("ddve-install-form-btn")) {
      runBookSteps("ddve-install-form-btn");
      return false;
    }
  }

  if (
    formType == "ave-install-form" &&
    checkButtonAttr("ave-install-form-btn")
  ) {
    runBookSteps("ave-install-form-btn");
    return false;
  }

  if (
    formType == "networker-install-form" &&
    checkButtonAttr("networker-install-form-btn")
  ) {
    runBookSteps("networker-install-form-btn");
    return false;
  }

  
  if (
    formType == "networker-proxy-install-form" &&
    checkButtonAttr("networker-proxy-install-form-btn")
  ) {
    runBookSteps("networker-proxy-install-form-btn");
    return false;
  }

  if (
    formType == "proxy-install-form" &&
    checkButtonAttr("proxy-install-form-btn")
  ) {
    runBookSteps("proxy-install-form-btn");
    return false;
  }

  if (
    formType == "ppdm-install-form" &&
    checkButtonAttr("ppdm-install-form-btn")
  ) {
    runBookSteps("ppdm-install-form-btn");
    return false;
  }
  if (
    formType == "ntp-install-form" &&
    checkButtonAttr("ntp-install-form-btn")
  ) {
    runBookSteps("ntp-install-form-btn");
    return false;
  }

  var runShell = true
  if(runShell){
    runWinShell("cr-form", "cr-install");
    runWinShell("cs-install-form", "cs-install");
    runWinShell("ave-install-form", "ave-install");
    runWinShell("ddve-install-form", "ddve-install");
    runWinShell("networker-install-form", "networker-install");
    runWinShell("networker-proxy-install-form", "networker-proxy-install");
    runWinShell("proxy-install-form", "proxy-install");
    runWinShell("ppdm-install-form", "ppdm-install");
    runWinShell("ntp-install-form", "ntp-install");
    runWinShell("dns-install-form", "dns-install");
  }
  
  finalStep();
  return false;
}

function runWinShell(formType, shFile) {
  var is_skip = parseInt($("#" + formType).attr("is-skip"));

  if (is_skip != 1) {
    //console.log($("#" + formType))
    var splitForm = formType.split('-')
    var formInput = $("#" + formType).serialize();

    var r = splitForm[0]
    if(formType == 'networker-proxy-install-form'){
      r = r+"-proxy"
    }
    var randomString1 = r+"-"+randomString(20)+".txt";
    document.getElementById(formType+"-random").value = randomString1;
    formInput = formInput+"&logfile="+randomString1;
    //decode back serialize string to original spl characters
    var decodedForm = decodeURIComponent(formInput);
    // replace ' ' with %20
    var replaceSpace = decodedForm.replace(/\ /g, "%20");

    console.log(r)
    console.log(replaceSpace);

    // Run script
    WshShell = new ActiveXObject("WScript.Shell");
    // //shFile = shFile+"-wizard"
    var script = "deploy.sh " + shFile + " " + replaceSpace;
    WshShell.Run(script, 1, false);
  }
}

function finalStep() {
  var formStepElements = document.querySelectorAll(".form-step");
  for (var i = 0; i < formStepElements.length; i++) {
    //console.log(formStepElements[i].getAttribute("id"));
    if (formStepElements[i].getAttribute("id") != "final-step")
      formStepElements[i].classList.add("d-none");
  }
  document.getElementById("power-edge").classList.add("d-none")
  document.querySelector("#final-step").classList.remove("d-none");

  var formStepElements1 = document.querySelectorAll("section");
  var htmlContent = "";
  for (var i = 0; i < formStepElements1.length; i++) {
    var statusId = formStepElements1[i].getAttribute("status-id");
    var status = ["cyber-recovery-status", 
                  "cyber-sense-status", "data-domain-status", 
                  "avamar-status", "networker-status", "networker-proxy-status", 
                  "avamar-proxy-status", "data-manager-status", "ntp-status", "dns-status"] //, "power-scale-status", "open-stack", "open-stack-provisioning", "power-store-status"
    //if(status.indexOf(statusId) == -1)
    {
      var id = formStepElements1[i].getAttribute("id");
      var cardId = "#" + statusId + " .card";
      if (id != "step-1" && id != "final-step") {
        if (formStepElements1[i].getAttribute("is-modified") == "1" && status.indexOf(statusId) > -1) {
          var status_id = formStepElements1[i].getAttribute("status-id"); //formStepElements1[i].getAttribute('status-id');
          document.getElementById(status_id).classList.remove("d-none")
          if (
            formStepElements1[i].getAttribute("status-id") ==
            "cyber-recovery-status"
          ) {
            cyberRecoveryStatus(status_id);
          } else if (
            formStepElements1[i].getAttribute("status-id") == "cyber-sense-status"
          ) {
            cyberSenseStatus(status_id);
          } else if (
            formStepElements1[i].getAttribute("status-id") == "data-domain-status"
          ) {
            dataDomainStatus(status_id);
          } else if (
            formStepElements1[i].getAttribute("status-id") == "avamar-status"
          ) {
            avamarStatus(status_id);
          } else if (
            formStepElements1[i].getAttribute("status-id") == "networker-status"
          ) {
            networkerStatus(status_id);
          } else if (
            formStepElements1[i].getAttribute("status-id") == "networker-proxy-status"
          ) {
            networkerProxyStatus(status_id);
          } else if (
            formStepElements1[i].getAttribute("status-id") ==
            "avamar-proxy-status"
          ) {
            avamarProxyStatus(status_id);
          } else if (
            formStepElements1[i].getAttribute("status-id") ==
            "data-manager-status"
          ) {
            dataManagerStatus(status_id);
          } else if (
            formStepElements1[i].getAttribute("status-id") == "ntp-status"
          ) {
            ntpStatus(status_id);
          } else if (
            formStepElements1[i].getAttribute("status-id") == "dns-status"
          ) {
            dnsStatus(status_id);
          }
        } else if(status.indexOf(statusId) > -1){
           document.getElementById(statusId).classList.remove("d-none")
          statusList(cardId, "dl-progress", "dl-inactive", 1);
        }
      }
    }
    

    //setInterval(function() { checkStatus(formStepElements1[i].getAttribute('status-id')); }, 5000);
  }
}

function callXhr1(id, file) {
  var cardId = "#" + id + " .card";
  var currentStatus = $("#hidden-"+id).val();
  if (currentStatus == "InProgress") {
    //alert("http://localhost/"+file)
    createXhrRequest(
      "GET",
      "http://localhost/" + file, cardId, id);
  }
}

function createXhrRequest(httpMethod, url, cardId, id) {
  
  var xhr = new XMLHttpRequest();
  xhr.open( httpMethod, url );

  xhr.onload = function() {
    if (xhr.readyState == 4 && xhr.status == 200) {
        if (this.responseText.indexOf("Failed") !== -1) {
          statusList(cardId, "dl-progress", "dl-error", 3);
          $("#hidden-"+id).val("Failed");
        }
  
        if (this.responseText.indexOf("Success") !== -1) {
          statusList(cardId, "dl-progress", "dl-success", 2);
          $("#hidden-"+id).val("Success");
        }
      }
  }; 

  xhr.send();
}

function statusList(cardId, statusFrom, statusTo, index) {
  
  document.querySelector(cardId).classList.remove(statusFrom);
  document.querySelector(cardId).classList.add(statusTo);
  var dlMsgList = document.querySelectorAll(cardId + " .dl-msg");
  for (var j = 0; j < dlMsgList.length; j++) {
    var dlMsgList1 = dlMsgList[j];
    //console.log(dlMsgList1);
    if (j == index) dlMsgList1.style.display = "block";
    else dlMsgList1.style.display = "none";
  }
}

function cyberRecoveryStatus(id) {
  var status = setInterval(function () {
    callXhr(id, $("#cr-form-random").val());
    var currentStatus = $("#hidden-"+id).val();
    if (currentStatus != "InProgress") {
      clearInterval(status);
    }
  }, 10000);
}

function cyberSenseStatus(id) {
  var status1 = setInterval(function () {
    callXhr(id, $("#cs-install-form-random").val());
    var currentStatus = $("#hidden-"+id).val();
    if (currentStatus != "InProgress") {
      clearInterval(status1);
    }
  }, 10000);
}

function dataDomainStatus(id) {
  var status2 = setInterval(function () {
    callXhr(id, $("#ddve-install-form-random").val());
    var currentStatus = $("#hidden-"+id).val();
    if (currentStatus != "InProgress") {
      clearInterval(status2);
    }
  }, 10000);
}

function avamarStatus(id) {
  var status3 = setInterval(function () {
    callXhr(id, $("#ave-install-form-random").val());
    var currentStatus = $("#hidden-"+id).val();
    if (currentStatus != "InProgress") {
      clearInterval(status3);
    }
  }, 10000);
}

function networkerStatus(id) {
  var status4 = setInterval(function () {
    callXhr(id, $("#networker-install-form-random").val());
    var currentStatus = $("#hidden-"+id).val();
    if (currentStatus != "InProgress") {
      clearInterval(status4);
    }
  }, 10000);
}

function networkerProxyStatus(id) {
  var status9 = setInterval(function () {
    callXhr(id, $("#networker-proxy-install-form-random").val());
    var currentStatus = $("#hidden-"+id).val();
//alert(currentStatus+" === "+ $("#networker-proxy-install-form-random").val())
    if (currentStatus != "InProgress") {
      clearInterval(status9);
    }
  }, 10000);
}

function avamarProxyStatus(id) {
  var status5 = setInterval(function () {
    callXhr(id, $("#proxy-install-form-random").val());
    var currentStatus = $("#hidden-"+id).val();
    if (currentStatus != "InProgress") {
      clearInterval(status5);
    }
  }, 10000);
}

function dataManagerStatus(id) {
  var status6 = setInterval(function () {
    callXhr(id, $("#ppdm-install-form-random").val());
    var currentStatus = $("#hidden-"+id).val();
    if (currentStatus != "InProgress") {
      clearInterval(status6);
    }
  }, 10000);
}

function ntpStatus(id) {
  var status7 = setInterval(function () {
    callXhr(id, $("#ntp-install-form-random").val());
    var currentStatus = $("#hidden-"+id).val();
    if (currentStatus != "InProgress") {
      clearInterval(status7);
    }
  }, 10000);
}

function dnsStatus(id) {
  var status8 = setInterval(function () {
    callXhr(id, $("#dns-install-form-random").val());
    var currentStatus = $("#hidden-"+id).val();
    if (currentStatus != "InProgress") {
      clearInterval(status8);
    }
  }, 10000);
}

function callXhr(id, file) {
  setTimeout(function () {
    callXhr1(id, file);
  }, 10000);
}



/*function checkStatus(id, file){
  if(document.getElementById(id).value=='inprogress')
  {
    const xhttp = new XMLHttpRequest();
    xhttp.onload = function() {
      if(this.responseText == "Failed"){
        // document.querySelector(
        //   "."+id+" .loader"
        // );
      }
    }
    xhttp.open("GET", "http://localhost/"+file);
    xhttp.send();
  }  
}*/

function checkButtonAttr(btn) {
  if (document.getElementById(btn).hasAttribute("step")) {
    return true;
  } else {
    return false;
  }
}

function randomString(length) {
  var chars = "0123456789abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ";
  var result = "";
  for (var i = length; i > 0; --i)
    result += chars[Math.floor(Math.random() * chars.length)];
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
  for (var i = 0; i < formArray.length; i++) {
    returnArray[formArray[i]["name"]] = formArray[i]["value"];
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
    if (inputs[i].type != "file") {
      if (
        inputs[i].name != "VMName" &&
        inputs[i].name != "fqdn" &&
        inputs[i].name != "ovaPath" &&
        formInput[inputs[i].name]
      ) {
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
        if (inputs[i].name == "ntpName") inputs[i].value = formInput["NTP"];
      }
    }

    // if (destinationForm == "dns-install-form") {
    //   if (inputs[i].name == "server")
    //     inputs[i].value = formInput["ip_cr"];
    // }
  }
}
