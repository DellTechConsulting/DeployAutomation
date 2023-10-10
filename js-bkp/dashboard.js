$(document).ready(function () {
  $(".alert").hide();
  //Onload CR is selected by-default
  $(".cr").show();
  $("#sidebar a[id='cr']").addClass("active");

  //Make vCenter details required fields
  $(
    "#cr-vCenter-text,#cr-vCenter-username-text,#cr-vCenter-password-text,#cr_esxiHost input,#cs-vCenter-text,#cs-vCenter-username-text,#cs-vCenter-password-text,#cs_esxiHost input,#ave-vCenter-text,#ave-vCenter-username-text,#ave-vCenter-password-text,#ave_esxiHost input,#networker-vCenter-text,#networker-vCenter-username-text,#networker-vCenter-password-text,#networker_esxiHost input,#proxy-vCenter-text,#proxy-vCenter-username-text,#proxy-vCenter-password-text,#proxy_esxiHost input,#ppdm-vCenter-text,#ppdm-vCenter-username-text,#ppdm-vCenter-password-text,#ppdm_esxiHost input"
  ).attr("required", true);

  $(
    "#cr-ESXi-text,#cr-ESXi-username-text,#cr-ESXi-password-text,#cs-ESXi-text,#cs-ESXi-username-text,#cs-ESXi-password-text,#ave-ESXi-text,#ave-ESXi-username-text,#ave-ESXi-password-text,#networker-ESXi-text,#networker-ESXi-username-text,#networker-ESXi-password-text,#proxy-ESXi-text,#proxy-ESXi-username-text,#proxy-ESXi-password-text,#ppdm-ESXi-text,#ppdm-ESXi-username-text,#ppdm-ESXi-password-text"
  ).attr("disabled", true);

  //Onload CS-Install is shown & CS-Integrate is hidden
  $("#cs_install").addClass("active");
  $(".install-section").show();
  $(".integrate-section").hide();

  //Onload AVE-Install is shown & AVE-Integrate is hidden
  $("#ave_install").addClass("active");
  $(".ave-install-section").show();
  $(".ave-integrate-section").hide();

  //Onload DDVE-Install is shown & DDVE-Integrate is hidden
  $("#ddve_install").addClass("active");
  $(".ddve-install-section").show();
  $(".ddve-integrate-section").hide();

  //Left navigation menu
  $("#sidebar a").click(function () {
    $(".collapse.list-unstyled").removeClass("show");
    $("#sidebar a").removeClass("active");
    $(this).addClass("active");

    var selectedItem = $(this).attr("id");
    var targetComponent = $("." + selectedItem);
    $(".select").not(targetComponent).hide();
    $(targetComponent).show();
  });

  // Cyber Sense Installation section
  $("#cs_install").click(function () {
    $(this).addClass("active");
    $("#cs_integrate").removeClass("active");
    $(".install-section").show();
    $(".integrate-section").hide();
  });

  // Cyber Sense Integrate section
  $("#cs_integrate").click(function () {
    $("#cs_install").removeClass("active");
    $(this).addClass("active");
    $(".install-section").hide();
    $(".integrate-section").show();
  });

  // Avamar Installation section
  $("#ave_install").click(function () {
    $(this).addClass("active");
    $("#ave_integrate").removeClass("active");
    $(".ave-install-section").show();
    $(".ave-integrate-section").hide();
  });

  // Avamar Integrate section
  $("#ave_integrate").click(function () {
    $("#ave_install").removeClass("active");
    $(this).addClass("active");
    $(".ave-install-section").hide();
    $(".ave-integrate-section").show();
  });

  // DDVE Installation section
  $("#ddve_install").click(function () {
    $(this).addClass("active");
    $("#ddve_integrate").removeClass("active");
    $(".ddve-install-section").show();
    $(".ddve-integrate-section").hide();
  });

  // DDVE Integrate section
  $("#ddve_integrate").click(function () {
    $("#ddve_install").removeClass("active");
    $(this).addClass("active");
    $(".ddve-install-section").hide();
    $(".ddve-integrate-section").show();
  });

  // CR VCenter section
  $("#cr-tab1").click(function () {
    $("#cr-tab2").removeClass("active");
    $(this).addClass("active");
    $("#cr-ESXi").hide();
    $("#cr-vCenter,#cr_esxiHost").show();

    $(
      "#cr-vCenter-text,#cr-vCenter-username-text,#cr-vCenter-password-text,#cr-radio-one,#cr-radio-two,#cr-host-input"
    ).removeAttr("disabled");
    $(
      "#cr-vCenter-text,#cr-vCenter-username-text,#cr-vCenter-password-text,#cr-radio-one,#cr-radio-two,#cr-host-input"
    ).attr("required", true);

    $("#cr-ESXi-text,#cr-ESXi-username-text,#cr-ESXi-password-text").removeAttr(
      "required"
    );
    $("#cr-ESXi-text,#cr-ESXi-username-text,#cr-ESXi-password-text").val("");
    $("#cr-ESXi-text,#cr-ESXi-username-text,#cr-ESXi-password-text").attr(
      "disabled",
      true
    );

    $("#cr-deployment-type").val("vCenter");
  });

  // CR ESXi section
  $("#cr-tab2").click(function () {
    $("#cr-tab1").removeClass("active");
    $(this).addClass("active");
    $("#cr-ESXi").show();
    $("#cr-vCenter,#cr_esxiHost").hide();

    $("#cr-ESXi-text,#cr-ESXi-username-text,#cr-ESXi-password-text").removeAttr(
      "disabled"
    );
    $("#cr-ESXi-text,#cr-ESXi-username-text,#cr-ESXi-password-text").attr(
      "required",
      true
    );
    $(
      "#cr-vCenter-text,#cr-vCenter-username-text,#cr-vCenter-password-text,#cr-radio-one,#cr-radio-two,#cr-host-input"
    ).removeAttr("required");
    $(
      "#cr-vCenter-text,#cr-vCenter-username-text,#cr-vCenter-password-text"
    ).val("");
    $(
      "#cr-vCenter-text,#cr-vCenter-username-text,#cr-vCenter-password-text,#cr-radio-one,#cr-radio-two,#cr-host-input"
    ).attr("disabled", true);

    $("#cr-deployment-type").val("ESXi");
  });

  // CR VCenter section
  $("#cr-tab3").click(function () {
    $("#cr-tab4").removeClass("active");
    $(this).addClass("active");
    $("#cr-ESXi1").hide();
    $("#cr-vCenter1,#cr_esxiHost1").show();
    var vcenterCR = "#cr-vCenter-text1,#cr-vCenter-username-text1,#cr-vCenter-password-text1,#cr-radio-one1,#cr-radio-two1,#cr-host-input1"
    $(
      vcenterCR
    ).removeAttr("disabled");
    $(
      vcenterCR
    ).attr("required", true);
    

    $("#cr-ESXi-text1,#cr-ESXi-username-text1,#cr-ESXi-password-text1").removeAttr(
      "required"
    );
    $("#cr-ESXi-text1,#cr-ESXi-username-text1,#cr-ESXi-password-text1").val("");
    $("#cr-ESXi-text1,#cr-ESXi-username-text1,#cr-ESXi-password-text1").attr(
      "disabled",
      true
    );

    $("#cr-deployment-type1").val("vCenter");
  });

  // CR ESXi section
  $("#cr-tab4").click(function () {
    $("#cr-tab3").removeClass("active");
    $(this).addClass("active");
    $("#cr-ESXi1").show();
    $("#cr-vCenter1,#cr_esxiHost1").hide();

    $("#cr-ESXi-text1,#cr-ESXi-username-text1,#cr-ESXi-password-text1").removeAttr(
      "disabled"
    );
    $("#cr-ESXi-text1,#cr-ESXi-username-text1,#cr-ESXi-password-text1").attr(
      "required",
      true
    );

    var vCenterTab2 = "#cr-vCenter-text1,#cr-vCenter-username-text1,#cr-vCenter-password-text1,#cr-radio-one1,#cr-radio-two1,#cr-host-input1"
    $(
      vCenterTab2
    ).removeAttr("required");
    $(
      "#cr-vCenter-text1,#cr-vCenter-username-text1,#cr-vCenter-password-text1"
    ).val("");
    $(
      vCenterTab2
    ).attr("disabled", true);

    $("#cr-deployment-type1").val("ESXi");
  });

  // CS VCenter section
  $("#cs-tab1").click(function () {
    $("#cs-tab2").removeClass("active");
    $(this).addClass("active");
    $("#cs-ESXi").hide();
    $("#cs-vCenter,#cs_esxiHost").show();

    $(
      "#cs-vCenter-text,#cs-vCenter-username-text,#cs-vCenter-password-text,#cs-radio-one,#cs-radio-two,#cs-host-input"
    ).removeAttr("disabled");

    $(
      "#cs-vCenter-text,#cs-vCenter-username-text,#cs-vCenter-password-text,#cs-radio-one,#cs-radio-two,#cs-host-input"
    ).attr("required", true);
    $("#cs-ESXi-text,#cs-ESXi-username-text,#cs-ESXi-password-text").removeAttr(
      "required"
    );
    $("#cs-ESXi-text,#cs-ESXi-username-text,#cs-ESXi-password-text").val("");
    $("#cs-ESXi-text,#cs-ESXi-username-text,#cs-ESXi-password-text").attr(
      "disabled",
      true
    );

    $("#cs-deployment-type").val("vCenter");
  });

  // CS ESXi section
  $("#cs-tab2").click(function () {
    $("#cs-tab1").removeClass("active");
    $(this).addClass("active");
    $("#cs-ESXi").show();
    $("#cs-vCenter,#cs_esxiHost").hide();

    $("#cs-ESXi-text,#cs-ESXi-username-text,#cs-ESXi-password-text").removeAttr(
      "disabled"
    );

    $("#cs-ESXi-text,#cs-ESXi-username-text,#cs-ESXi-password-text").attr(
      "required",
      true
    );
    $(
      "#cs-vCenter-text,#cs-vCenter-username-text,#cs-vCenter-password-text,#cs-radio-one,#cs-radio-two,#cs-host-input"
    ).removeAttr("required");
    $(
      "#cs-vCenter-text,#cs-vCenter-username-text,#cs-vCenter-password-text"
    ).val("");
    $(
      "#cs-vCenter-text,#cs-vCenter-username-text,#cs-vCenter-password-text,#cs-radio-one,#cs-radio-two,#cs-host-input"
    ).attr("disabled", true);

    $("#cs-deployment-type").val("ESXi");
  });

  // CS VCenter section
  $("#cs-tab3").click(function () {
    $("#cs-tab4").removeClass("active");
    $(this).addClass("active");
    $("#cs-ESXi1").hide();
    $("#cs-vCenter1,#cs_esxiHost1").show();
    let csVenter1 = "#cs-vCenter-text1,#cs-vCenter-username-text1,#cs-vCenter-password-text1,#cs-radio-one1,#cs-radio-two1,#cs-host-input1"
    $(
      csVenter1
    ).removeAttr("disabled");

    $(
      csVenter1
    ).attr("required", true);
    $("#cs-ESXi-text1,#cs-ESXi-username-text1,#cs-ESXi-password-text1").removeAttr(
      "required"
    );
    $("#cs-ESXi-text1,#cs-ESXi-username-text1,#cs-ESXi-password-text1").val("");
    $("#cs-ESXi-text1,#cs-ESXi-username-text1,#cs-ESXi-password-text1").attr(
      "disabled",
      true
    );

    $("#cs-deployment-type1").val("vCenter");
  });

  // CS ESXi section
  $("#cs-tab4").click(function () {
    $("#cs-tab3").removeClass("active");
    $(this).addClass("active");
    $("#cs-ESXi1").show();
    $("#cs-vCenter1,#cs_esxiHost1").hide();

    $("#cs-ESXi-text1,#cs-ESXi-username-text1,#cs-ESXi-password-text1").removeAttr(
      "disabled"
    );

    $("#cs-ESXi-text1,#cs-ESXi-username-text1,#cs-ESXi-password-text1").attr(
      "required",
      true
    );
    let csVenter1 = "#cs-vCenter-text1,#cs-vCenter-username-text1,#cs-vCenter-password-text1,#cs-radio-one1,#cs-radio-two1,#cs-host-input1"
    $(
      csVenter1
    ).removeAttr("required");
    $(
      "#cs-vCenter-text1,#cs-vCenter-username-text1,#cs-vCenter-password-text1"
    ).val("");
    $(
      csVenter1
    ).attr("disabled", true);

    $("#cs-deployment-type1").val("ESXi");
  });

  // AVE VCenter section
  $("#ave-tab1").click(function () {
    $("#ave-tab2").removeClass("active");
    $(this).addClass("active");
    $("#ave-ESXi").hide();
    $("#ave-vCenter,#ave_esxiHost").show();

    $(
      "#ave-vCenter-text,#ave-vCenter-username-text,#ave-vCenter-password-text,#ave-radio-one,#ave-radio-two,#ave-host-input"
    ).removeAttr("disabled");

    $(
      "#ave-vCenter-text,#ave-vCenter-username-text,#ave-vCenter-password-text,#ave-radio-one,#ave-radio-two,#ave-host-input"
    ).attr("required", true);
    $(
      "#ave-ESXi-text,#ave-ESXi-username-text,#ave-ESXi-password-text"
    ).removeAttr("required");
    $("#ave-ESXi-text,#ave-ESXi-username-text,#ave-ESXi-password-text").val("");
    $("#ave-ESXi-text,#ave-ESXi-username-text,#ave-ESXi-password-text").attr(
      "disabled",
      true
    );

    $("#ave-deployment-type").val("vCenter");
  });

  // AVE ESXi section
  $("#ave-tab2").click(function () {
    $("#ave-tab1").removeClass("active");
    $(this).addClass("active");
    $("#ave-ESXi").show();
    $("#ave-vCenter,#ave_esxiHost").hide();

    $(
      "#ave-ESXi-text,#ave-ESXi-username-text,#ave-ESXi-password-text"
    ).removeAttr("disabled");

    $("#ave-ESXi-text,#ave-ESXi-username-text,#ave-ESXi-password-text").attr(
      "required",
      true
    );
    $(
      "#ave-vCenter-text,#ave-vCenter-username-text,#ave-vCenter-password-text,#ave-radio-one,#ave-radio-two,#ave-host-input"
    ).removeAttr("required");
    $(
      "#ave-vCenter-text,#ave-vCenter-username-text,#ave-vCenter-password-text"
    ).val("");
    $(
      "#ave-vCenter-text,#ave-vCenter-username-text,#ave-vCenter-password-text,#ave-radio-one,#ave-radio-two,#ave-host-input"
    ).attr("disabled", true);

    $("#ave-deployment-type").val("ESXi");
  });

  // AVE VCenter section
  $("#ave-tab3").click(function () {
    $("#ave-tab4").removeClass("active");
    $(this).addClass("active");
    $("#ave-ESXi1").hide();
    $("#ave-vCenter1,#ave_esxiHost1").show();

    $(
      "#ave-vCenter-text1,#ave-vCenter-username-text1,#ave-vCenter-password-text1,#ave-radio-one1,#ave-radio-two1,#ave-host-input1"
    ).removeAttr("disabled");

    $(
      "#ave-vCenter-text1,#ave-vCenter-username-text1,#ave-vCenter-password-text1,#ave-radio-one1,#ave-radio-two1,#ave-host-input1"
    ).attr("required", true);
    $(
      "#ave-ESXi-text1,#ave-ESXi-username-text1,#ave-ESXi-password-text1"
    ).removeAttr("required");
    $("#ave-ESXi-text1,#ave-ESXi-username-text1,#ave-ESXi-password-text1").val("");
    $("#ave-ESXi-text1,#ave-ESXi-username-text1,#ave-ESXi-password-text1").attr(
      "disabled",
      true
    );

    $("#ave-deployment-type1").val("vCenter");
  });

  // AVE ESXi section
  $("#ave-tab4").click(function () {
    $("#ave-tab3").removeClass("active");
    $(this).addClass("active");
    $("#ave-ESXi1").show();
    $("#ave-vCenter1,#ave_esxiHost1").hide();

    $(
      "#ave-ESXi-text1,#ave-ESXi-username-text1,#ave-ESXi-password-text1"
    ).removeAttr("disabled");

    $("#ave-ESXi-text1,#ave-ESXi-username-text1,#ave-ESXi-password-text1").attr(
      "required",
      true
    );
    $(
      "#ave-vCenter-text1,#ave-vCenter-username-text1,#ave-vCenter-password-text1,#ave-radio-one1,#ave-radio-two1,#ave-host-input1"
    ).removeAttr("required");
    $(
      "#ave-vCenter-text1,#ave-vCenter-username-text1,#ave-vCenter-password-text1"
    ).val("");
    $(
      "#ave-vCenter-text1,#ave-vCenter-username-text1,#ave-vCenter-password-text1,#ave-radio-one1,#ave-radio-two1,#ave-host-input1"
    ).attr("disabled", true);

    $("#ave-deployment-type1").val("ESXi");
  });

  $("#use_common_password").change(function () {
    var value = $("option:selected", this).val();
    if (value == "true") {
      $("#mandatory").removeClass("not-required");
      $("#common_password").attr("required", true);
      var commomPwd = $("#common_password").val();
      $(
        "#repl_password,#mcpass,#viewuserpass,#admin_password_os,#root_password_os,#keystore_passphrase,#avamar_rootpass"
      ).val(commomPwd);
      $(
        "#repl_password,#mcpass,#viewuserpass,#admin_password_os,#root_password_os,#keystore_passphrase,#avamar_rootpass"
      ).addClass("disabled");
      $("#common_password").removeClass("disabled");
    } else {
      $("#mandatory").addClass("not-required");
      $(
        "#common_password,#repl_password,#mcpass,#viewuserpass,#admin_password_os,#root_password_os,#keystore_passphrase,#avamar_rootpass"
      ).val("");
      $("#common_password").removeAttr("required");
      $(
        "#repl_password,#mcpass,#viewuserpass,#admin_password_os,#root_password_os,#keystore_passphrase,#avamar_rootpass"
      ).removeClass("disabled");
      $("#common_password").val("");
      $("#common_password").addClass("disabled");
    }
  });

  $("#common_password").blur(function () {
    var commomPwd = $("#common_password").val();
    $(
      "#repl_password,#mcpass,#viewuserpass,#admin_password_os,#root_password_os,#keystore_passphrase,#avamar_rootpass"
    ).val(commomPwd);
  });

  //Run book
  $("#use_common_password1").change(function () {
    var value = $("option:selected", this).val();
    if (value == "true") {
      $("#mandatory1").removeClass("not-required");
      $("#common_password1").attr("required", true);
      var commomPwd = $("#common_password1").val();
      var pswds = "#repl_password1,#mcpass1,#viewuserpass1,#admin_password_os1,#root_password_os1,#keystore_passphrase1,#avamar_rootpass1";
      $(
        pswds
      ).val(commomPwd);
      $(
        pswds
      ).addClass("disabled");
      $("#common_password1").removeClass("disabled");
    } else {
      $("#mandatory1").addClass("not-required");

      var pswds1 = "#common_password1, #repl_password1,#mcpass1,#viewuserpass1,#admin_password_os1,#root_password_os1,#keystore_passphrase1,#avamar_rootpass1";
      $(
        pswds1
      ).val("");
      $("#common_password1").removeAttr("required");
      $(
        pswds
      ).removeClass("disabled");
      $("#common_password1").val("");
      $("#common_password1").addClass("disabled");
    }
  });

  $("#common_password1").blur(function () {
    var commomPwd = $("#common_password1").val();
    var pswds = "#repl_password1,#mcpass1,#viewuserpass1,#admin_password_os1,#root_password_os1,#keystore_passphrase1,#avamar_rootpass1";
    $(
      pswds
    ).val(commomPwd);
  });


  // Networker VCenter section
  $("#networker-tab1").click(function () {
    $("#networker-tab2").removeClass("active");
    $(this).addClass("active");
    $("#networker-ESXi").hide();
    $("#networker-vCenter,#networker_esxiHost").show();

    $(
      "#networker-vCenter-text,#networker-vCenter-username-text,#networker-vCenter-password-text,#net-radio-one,#net-radio-two,#net-host-input"
    ).removeAttr("disabled");

    $(
      "#networker-vCenter-text,#networker-vCenter-username-text,#networker-vCenter-password-text,#net-radio-one,#net-radio-two,#net-host-input"
    ).attr("required", true);
    $("#networker-ESXi-text,#networker-ESXi-username-text,#networker-ESXi-password-text").removeAttr(
      "required"
    );
    $("#networker-ESXi-text,#networker-ESXi-username-text,#networker-ESXi-password-text").val("");
    $("#networker-ESXi-text,#networker-ESXi-username-text,#networker-ESXi-password-text").attr(
      "disabled",
      true
    );

    $("#networker-deployment-type").val("vCenter");
  });

  // Networker ESXi section
  $("#networker-tab2").click(function () {
    $("#networker-tab1").removeClass("active");
    $(this).addClass("active");
    $("#networker-ESXi").show();
    $("#networker-vCenter,#networker_esxiHost").hide();

    $("#networker-ESXi-text,#networker-ESXi-username-text,#networker-ESXi-password-text").removeAttr(
      "disabled"
    );

    $("#networker-ESXi-text,#networker-ESXi-username-text,#networker-ESXi-password-text").attr(
      "required",
      true
    );
    $(
      "#networker-vCenter-text,#networker-vCenter-username-text,#networker-vCenter-password-text,#net-radio-one,#net-radio-two,#net-host-input"
    ).removeAttr("required");
    $(
      "#networker-vCenter-text,#networker-vCenter-username-text,#networker-vCenter-password-text"
    ).val("");
    $(
      "#networker-vCenter-text,#networker-vCenter-username-text,#networker-vCenter-password-text,#net-radio-one,#net-radio-two,#net-host-input"
    ).attr("disabled", true);

    $("#networker-deployment-type").val("ESXi");
  });

  // Networker VCenter section
  $("#networker-tab3").click(function () {
    $("#networker-tab4").removeClass("active");
    $(this).addClass("active");
    $("#networker-ESXi1").hide();
    $("#networker-vCenter1,#networker_esxiHost1").show();

    var networkerVCenterID = "#networker-vCenter-text1,#networker-vCenter-username-text1,#networker-vCenter-password-text1,#net-radio-one1,#net-radio-two1,#net-host-input1";
    $(
      networkerVCenterID
    ).removeAttr("disabled");

    $(
      networkerVCenterID
    ).attr("required", true);
    var networkerESXi = "#networker-ESXi-text1,#networker-ESXi-username-text1,#networker-ESXi-password-text1";
    $(networkerESXi).removeAttr(
      "required"
    );
    $(networkerESXi).val("");
    $(networkerESXi).attr(
      "disabled",
      true
    );

    $("#networker-deployment-type1").val("vCenter");
  });

  // Networker ESXi section
  $("#networker-tab4").click(function () {
    $("#networker-tab3").removeClass("active");
    $(this).addClass("active");
    $("#networker-ESXi1").show();
    $("#networker-vCenter1,#networker_esxiHost1").hide();

    var networkerESXi = "#networker-ESXi-text1,#networker-ESXi-username-text1,#networker-ESXi-password-text1";

    $(networkerESXi).removeAttr(
      "disabled"
    );

    $(networkerESXi).attr(
      "required",
      true
    );

    var networkerVCenterID = "#networker-vCenter-text1,#networker-vCenter-username-text1,#networker-vCenter-password-text1,#net-radio-one1,#net-radio-two1,#net-host-input1";
    $(
      networkerVCenterID
    ).removeAttr("required");
    $(
      networkerVCenterID
    ).val("");
    $(
      networkerVCenterID
    ).attr("disabled", true);

    $("#networker-deployment-type1").val("ESXi");
  });

   // Proxy VCenter section
   $("#proxy-tab1").click(function () {
    $("#proxy-tab2").removeClass("active");
    $(this).addClass("active");
    $("#proxy-ESXi").hide();
    $("#proxy-vCenter,#proxy_esxiHost").show();

    $(
      "#proxy-vCenter-text,#proxy-vCenter-username-text,#proxy-vCenter-password-text,#proxy-radio-one,#proxy-radio-two,#proxy-host-input"
    ).removeAttr("disabled");

    $(
      "#proxy-vCenter-text,#proxy-vCenter-username-text,#proxy-vCenter-password-text,#proxy-radio-one,#proxy-radio-two,#proxy-host-input"
    ).attr("required", true);
    $("#proxy-ESXi-text,#proxy-ESXi-username-text,#proxy-ESXi-password-text").removeAttr(
      "required"
    );
    $("#proxy-ESXi-text,#proxy-ESXi-username-text,#proxy-ESXi-password-text").val("");
    $("#proxy-ESXi-text,#proxy-ESXi-username-text,#proxy-ESXi-password-text").attr(
      "disabled",
      true
    );

    $("#proxy-deployment-type").val("vCenter");
  });

  // Proxy ESXi section
  $("#proxy-tab2").click(function () {
    $("#proxy-tab1").removeClass("active");
    $(this).addClass("active");
    $("#proxy-ESXi").show();
    $("#proxy-vCenter,#proxy_esxiHost").hide();

    $("#proxy-ESXi-text,#proxy-ESXi-username-text,#proxy-ESXi-password-text").removeAttr(
      "disabled"
    );

    $("#proxy-ESXi-text,#proxy-ESXi-username-text,#proxy-ESXi-password-text").attr(
      "required",
      true
    );
    $(
      "#proxy-vCenter-text,#proxy-vCenter-username-text,#proxy-vCenter-password-text,#proxy-radio-one,#proxy-radio-two,#proxy-host-input"
    ).removeAttr("required");
    $(
      "#proxy-vCenter-text,#proxy-vCenter-username-text,#proxy-vCenter-password-text"
    ).val("");
    $(
      "#proxy-vCenter-text,#proxy-vCenter-username-text,#proxy-vCenter-password-text,#proxy-radio-one,#proxy-radio-two,#proxy-host-input"
    ).attr("disabled", true);

    $("#proxy-deployment-type").val("ESXi");
  });

  // Proxy VCenter section
  $("#proxy-tab3").click(function () {
    $("#proxy-tab4").removeClass("active");
    $(this).addClass("active");
    $("#proxy-ESXi1").hide();
    $("#proxy-vCenter1,#proxy_esxiHost1").show();

    var proxyVcenter = "#proxy-vCenter-text1,#proxy-vCenter-username-text1,#proxy-vCenter-password-text1,#proxy-radio-one1,#proxy-radio-two1,#proxy-host-input1"

    $(
      proxyVcenter
    ).removeAttr("disabled");

    $(
      proxyVcenter
    ).attr("required", true);
    var proxyESXi = "#proxy-ESXi-text1,#proxy-ESXi-username-text1,#proxy-ESXi-password-text1"
    $(proxyESXi).removeAttr(
      "required"
    );
    $(proxyESXi).val("");
    $(proxyESXi).attr(
      "disabled",
      true
    );

    $("#proxy-deployment-type1").val("vCenter");
  });

  // Proxy ESXi section
  $("#proxy-tab4").click(function () {
    $("#proxy-tab3").removeClass("active");
    $(this).addClass("active");
    $("#proxy-ESXi1").show();
    $("#proxy-vCenter1,#proxy_esxiHost1").hide();

    var proxyESXi = "#proxy-ESXi-text1,#proxy-ESXi-username-text1,#proxy-ESXi-password-text1"

    $(proxyESXi).removeAttr(
      "disabled"
    );

    $(proxyESXi).attr(
      "required",
      true
    );

    var proxyVcenter = "#proxy-vCenter-text1,#proxy-vCenter-username-text1,#proxy-vCenter-password-text1,#proxy-radio-one1,#proxy-radio-two1,#proxy-host-input1"
    $(
      proxyVcenter
    ).removeAttr("required");
    $(
      proxyVcenter
    ).val("");
    $(
      proxyVcenter
    ).attr("disabled", true);

    $("#proxy-deployment-type1").val("ESXi");
  });

   // PPDM VCenter section
   $("#ppdm-tab1").click(function () {
    $("#ppdm-tab2").removeClass("active");
    $(this).addClass("active");
    $("#ppdm-ESXi").hide();
    $("#ppdm-vCenter,#ppdm_esxiHost").show();

    $(
      "#ppdm-vCenter-text,#ppdm-vCenter-username-text,#ppdm-vCenter-password-text,#ppdm-radio-one,#ppdm-radio-two,#ppdm-host-input"
    ).removeAttr("disabled");

    $(
      "#ppdm-vCenter-text,#ppdm-vCenter-username-text,#ppdm-vCenter-password-text,#ppdm-radio-one,#ppdm-radio-two,#ppdm-host-input"
    ).attr("required", true);
    $("#ppdm-ESXi-text,#ppdm-ESXi-username-text,#ppdm-ESXi-password-text").removeAttr(
      "required"
    );
    $("#ppdm-ESXi-text,#ppdm-ESXi-username-text,#ppdm-ESXi-password-text").val("");
    $("#ppdm-ESXi-text,#ppdm-ESXi-username-text,#ppdm-ESXi-password-text").attr(
      "disabled",
      true
    );

    $("#ppdm-deployment-type").val("vCenter");
  });

  // PPDM ESXi section
  $("#ppdm-tab2").click(function () {
    $("#ppdm-tab1").removeClass("active");
    $(this).addClass("active");
    $("#ppdm-ESXi").show();
    $("#ppdm-vCenter,#ppdm_esxiHost").hide();

    $("#ppdm-ESXi-text,#ppdm-ESXi-username-text,#ppdm-ESXi-password-text").removeAttr(
      "disabled"
    );

    $("#ppdm-ESXi-text,#ppdm-ESXi-username-text,#ppdm-ESXi-password-text").attr(
      "required",
      true
    );
    $(
      "#ppdm-vCenter-text,#ppdm-vCenter-username-text,#ppdm-vCenter-password-text,#ppdm-radio-one,#ppdm-radio-two,#ppdm-host-input"
    ).removeAttr("required");
    $(
      "#ppdm-vCenter-text,#ppdm-vCenter-username-text,#ppdm-vCenter-password-text"
    ).val("");
    $(
      "#ppdm-vCenter-text,#ppdm-vCenter-username-text,#ppdm-vCenter-password-text,#ppdm-radio-one,#ppdm-radio-two,#ppdm-host-input"
    ).attr("disabled", true);

    $("#ppdm-deployment-type").val("ESXi");
  });

  // PPDM VCenter section
  $("#ppdm-tab3").click(function () {
    $("#ppdm-tab4").removeClass("active");
    $(this).addClass("active");
    $("#ppdm-ESXi1").hide();
    $("#ppdm-vCenter1,#ppdm_esxiHost1").show();

    var ppdmVcenter = "#ppdm-vCenter-text1,#ppdm-vCenter-username-text1,#ppdm-vCenter-password-text1,#ppdm-radio-one1,#ppdm-radio-two1,#ppdm-host-input1"
    $(
      ppdmVcenter
    ).removeAttr("disabled");

    $(
      ppdmVcenter
    ).attr("required", true);

    var ppdmESXi = "#ppdm-ESXi-text1,#ppdm-ESXi-username-text1,#ppdm-ESXi-password-text1"
    $(ppdmESXi).removeAttr(
      "required"
    );
    $(ppdmESXi).val("");
    $(ppdmESXi).attr(
      "disabled",
      true
    );

    $("#ppdm-deployment-type1").val("vCenter");
  });

  // PPDM ESXi section
  $("#ppdm-tab4").click(function () {
    $("#ppdm-tab3").removeClass("active");
    $(this).addClass("active");
    $("#ppdm-ESXi1").show();
    $("#ppdm-vCenter1,#ppdm_esxiHost1").hide();

    var ppdmESXi = "#ppdm-ESXi-text1,#ppdm-ESXi-username-text1,#ppdm-ESXi-password-text1"
    $(ppdmESXi).removeAttr(
      "disabled"
    );

    $(ppdmESXi).attr(
      "required",
      true
    );

    var ppdmVcenter = "#ppdm-vCenter-text1,#ppdm-vCenter-username-text1,#ppdm-vCenter-password-text1,#ppdm-radio-one1,#ppdm-radio-two1,#ppdm-host-input1"
    $(
      ppdmVcenter
    ).removeAttr("required");
    $(
      ppdmVcenter
    ).val("");
    $(
      ppdmVcenter
    ).attr("disabled", true);

    $("#ppdm-deployment-type1").val("ESXi");
  });

  
  $(".skip-btn").click(function(){
    if(parseInt($(this).attr('skip-finish')) == 1){
      $("#dns-install-form").attr('is-skip', 1)
      runWinShell("cr-form", "cr-install");
      runWinShell("cs-install-form", "cs-install");
      runWinShell("ave-install-form", "ave-install");
      runWinShell("networker-install-form", "networker-install");
      runWinShell("proxy-install-form", "proxy-install");
      runWinShell("ppdm-install-form", "ppdm-install");
      runWinShell("ntp-install-form", "ntp-install");
      runWinShell("dns-install-form", "dns-install");
      
    }
  })

  $("#cr-form-btn-1").click(function(e){
    e.preventDefault();
    // $("section").each(function(){
    //   if($(this).attr('id')!="1"){
    //     $(this).removeAttr('id')
    //   }
    // })
    $("#step-1").attr('is-modified',1)
    $("#final-step").attr('is-modified',1)
    console.log($("#cr-form-1 input:checkbox:checked").length)
    var steps_starts = 2;
    var step_forms = {
      "cr-form":["cr-form-btn",2],
      "cs-install-form":["cs-install-form-btn",3],
      "ddve-install-form":["ddve-install-form-btn",4],
      "ave-install-form":["ave-install-form-btn",5],
      "networker-install-form":["networker-install-form-btn",6],
      "proxy-install-form":["proxy-install-form-btn",7],
      "ppdm-install-form":["ppdm-install-form-btn",8],
      "ntp-install-form":["ntp-install-form-btn",9],
      "dns-install-form":["dns-install-form-btn",10],
    }
    var i=$("#cr-form-1 input:checkbox:checked").length;
    $("#cr-form-1 input:checkbox:checked").each(function() {
      i--;
      var btn = step_forms[$(this).val()][0]
      var stp = step_forms[$(this).val()][1]
      
      if(i == 0){
        // console.log(btn, stp, steps_starts, i)  
        $("#step-"+stp).attr('is-modified',1)
        
        $("#step-"+stp).attr('id', "step-"+steps_starts)
        $("#"+btn+"1").attr("step_number", steps_starts-1)
        $("#"+btn).html('<i class="bi bi-play"></i> Finish')
        $("#"+btn).removeAttr("step")
      }else{
        // console.log(btn, stp, steps_starts, i)  
        $("#step-"+stp).attr('is-modified',1)
        $("#"+btn).attr("step", steps_starts+1)
        $("#"+btn).html('<i class="bi bi-play"></i> Next')
        $("#"+btn+"1").attr("step_number", steps_starts-1)
        $("#step-"+stp).attr('id', "step-"+steps_starts)
      }
      steps_starts++;
      //console.log($(this).val())
      
    });

    $("section").each(function(){
        
        if($(this).attr('is-modified')!="1"){
          console.log($(this).attr('id'), $(this).attr('is-modified'))
          $(this).find('form').attr('is-skip', 1)
          $(this).removeAttr('id')
        }
    })
    navigateToFormStep(2);
    return false;
  })
  
  // $("#auto_fill_file1").change(function(){
  //   //var files = document.querySelector('#auto_fill_file1').files;
  //   var files = this.files;
  //   var form_name = $(this).attr('form-name')
  //   //if(files.length > 0 )
  //   {

  //       // Selected file
  //       var file = files[0];

  //       // FileReader Object
  //       var reader = new FileReader();

  //       // Read file as string 
  //       reader.readAsText(file);

  //       // Load event
  //       reader.onload = function(event) {

  //             // Read file data
  //             var csvdata = event.target.result;

  //             // Split by line break to gets rows Array
  //             var rowData = csvdata.split('\n');

  //             console.log(rowData)

              
  //             // <table > <tbody>
  //             // var tbodyEl = document.getElementById('tblcsvdata').getElementsByTagName('tbody')[0];
  //             // tbodyEl.innerHTML = "";

  //             // // Loop on the row Array (change row=0 if you also want to read 1st row)
  //             var arr = {}
  //             for (var row = 1; row < rowData.length; row++) {

  //                   // Insert a row at the end of table
  //             //      var newRow = tbodyEl.insertRow();

  //                   // Split by comma (,) to get column Array
  //                   rowColData = rowData[row].replace(/(\r\n|\n|\r)/gm, "").replace(/ /g,'').replace(/\s/g,'').split(',');
  //                   console.log(rowColData)
                    
  //                   //let x = []
  //                   // Loop on the row column Array
  //                   for (var col = 0; col < rowColData.length; col++) {

  //                     if(rowColData[col] != '\r' 
  //                       && rowColData[col] != '' 
  //                       && rowColData[col] != 'vcenter_details' 
  //                       && rowColData[col] != 'Esxi_details' 
  //                       && rowColData[col]!='CR_details'
  //                     ){
  //                       //console.log(rowColData[col])
  //                       if(rowColData[col+1] !== undefined && rowColData[col+1]!=''){
  //                         console.log(rowColData[col], rowColData[col+1])
  //                         var r = rowColData[col].toLowerCase()
  //                         arr[r] = rowColData[col+1]
  //                         //x.push(arr)
  //                       }                        
  //                     }

  //                   }

  //             }
  //             console.log(arr)
  //             formDataFill(form_name, arr)
  //       };

        


  //   }
  // })


  $(".prefill-data").change(function(){
    //var files = document.querySelector('#auto_fill_file1').files;
    var files = this.files;
    var form_name = $(this).attr('form-name')
    //if(files.length > 0 )
    {

        // Selected file
        var file = files[0];

        // FileReader Object
        var reader = new FileReader();

        // Read file as string 
        reader.readAsText(file);

        // Load event
        reader.onload = function(event) {

              // Read file data
              var csvdata = event.target.result;

              // Split by line break to gets rows Array
              var rowData = csvdata.split('\n');

              console.log(rowData)

              
              // <table > <tbody>
              // var tbodyEl = document.getElementById('tblcsvdata').getElementsByTagName('tbody')[0];
              // tbodyEl.innerHTML = "";

              // // Loop on the row Array (change row=0 if you also want to read 1st row)
              var arr = {}
              for (var row = 1; row < rowData.length; row++) {

                    // Insert a row at the end of table
              //      var newRow = tbodyEl.insertRow();

                    // Split by comma (,) to get column Array
                    rowColData = rowData[row].replace(/(\r\n|\n|\r)/gm, "").replace(/ /g,'').replace(/\s/g,'').split(',');
                    console.log(rowColData)
                    
                    //let x = []
                    // Loop on the row column Array
                    for (var col = 0; col < rowColData.length; col++) {

                      if(rowColData[col] != '\r' 
                        && rowColData[col] != '' 
                        && rowColData[col] != 'vcenter_details' 
                        && rowColData[col] != 'Esxi_details' 
                        && rowColData[col]!='CR_details'
                      ){
                        //console.log(rowColData[col])
                        if(rowColData[col+1] !== undefined && rowColData[col+1]!=''){
                          console.log(rowColData[col], rowColData[col+1])
                          var r = rowColData[col].toLowerCase()
                          arr[r] = rowColData[col+1]
                          //x.push(arr)
                        }                        
                      }

                    }

              }
              console.log(arr)
              formDataFill(form_name, arr)
        };

        


    }
  })


});

function formDataFill(formName, rowName){
  const inputs = document.querySelector('#'+formName).getElementsByTagName('input');
  for (var i=0; i<inputs.length; i++) {
      console.log(inputs[i].name)
      if(inputs[i].name!='' && inputs[i].name.toLowerCase()!='deploymenttype'){
        inputs[i].value= rowName[inputs[i].name.toLowerCase()] !== undefined ? rowName[inputs[i].name.toLowerCase()] : ""
        if(formName == "cr-form"){
          if(inputs[i].name.toLowerCase() == "mongodbpassword"){
            inputs[i].value= rowName['dbpassword'];
          }
          if(inputs[i].name.toLowerCase() == "ip_cr"){
            inputs[i].value= rowName['ip'];
          } 
        } 

        if(formName == "cs-install-form"){
          if(inputs[i].name.toLowerCase() == "ip_cs"){
            inputs[i].value= rowName['ip'];
          } 
          if(inputs[i].name.toLowerCase() == "netmask0"){
            inputs[i].value= rowName['netmask'];
          } 
          if(inputs[i].name.toLowerCase() == "confirmpassword"){
            inputs[i].value= rowName['newadminpass'];
          }           
        } 
        
        if(inputs[i].name == "host-value"){
          if(rowName['esxihost'] !== undefined){
            inputs[i].value= rowName['esxihost'];
            $("input[name='host-type'][value1='esxihost']").prop("checked", true)
            $("input[name='host-type'][value1='cluster']").prop("checked", false)
            $('#cr-radio-one1').prop("checked", true);
          }
          if(rowName['cluster'] !== undefined){
            inputs[i].value= rowName['cluster'];
            $("input[name='host-type'][value1='cluster']").prop("checked", true)
            $("input[name='host-type'][value1='esxihost']").prop("checked", false)
          }          
        } 
        if(inputs[i].name == "ovaPath"){
          $("#ovaPath-"+formName).removeAttr('required')
          //$("#ovaPath-"+formName).val(rowName['ovapath'])
        }
      }
  }
}
