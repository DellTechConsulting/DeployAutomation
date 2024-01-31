/*function checkInputs() {
  var isValid = true;
  const cr_form = document.querySelector("#cr_form");
  var inputs = cr_form.querySelectorAll('input[required]');

  inputs.forEach(function(input) {
    if (input.value === '') {
      document.getElementById('cr-form-btn').disabled = true;
      isValid = false;
      return false;
    }
  });

  if (isValid) {
    document.getElementById('cr-form-btn').disabled = false;
  }

  return isValid;
}
var runbook = document.getElementById('runbook')

console.log(runbook)

var cr_inputs = document.querySelector("#cr-form")
cr_inputs.forEach(function(input){
	console.log(cr_inputs)
})

runbook.addEventListener('click', function() {
  const cr_form_inputs = document.querySelector("#cr_form");
console.log(cr_form_inputs)
var requiredInputs = cr_form_inputs.querySelectorAll('input[required]');
requiredInputs.forEach(function(input) {
  input.addEventListener('keyup', function() {
    checkInputs();
  });
});
checkInputs();
});

let cr_form_btn = document.getElementById('cr-form-btn');
console.log(cr_form_btn)
cr_form_btn.addEventListener('click', function() {
  alert(checkInputs());
});

window.onload=function(){
    
// Enable or disable button based on if inputs are filled or not
/*const cr_form_inputs = document.querySelector("#cr_form");
var requiredInputs = cr_form_inputs.querySelectorAll('input[required]');
requiredInputs.forEach(function(input) {
  input.addEventListener('keyup', function() {
    checkInputs();
  });
});*/

//checkInputs();
//}


const inputs = document.querySelector('#cr-form').getElementsByTagName('input');
const inputs1 = document.querySelector('#cs-install-form').getElementsByTagName('input');
const inputs2 = document.querySelector('#ddve-install-form').getElementsByTagName('input');
const inputs3 = document.querySelector('#networker-proxy-install-form').getElementsByTagName('input');
/*highlightedItems.forEach((userItem) => {
    console.log(userItem)
userItem.value="TEST"
});*/

  for (var i=0; i<inputs.length; i++) {
    if (inputs[i].name != "vCenter" && inputs[i].name != "username" && inputs[i].name != "password")
     if(inputs[i].type.toLowerCase() === "password" || inputs[i].type.toLowerCase() === "text") {
      inputs[i].value=inputs[i].name
    }
	// if(inputs[i].type.toLowerCase() == "file"){
	// 	console.log(inputs[i].files)
	// }
  }


  for (var i=0; i<inputs1.length; i++) {
    if (inputs1[i].type.toLowerCase() === "password" || inputs1[i].type.toLowerCase() === "text") {
      inputs1[i].value=inputs1[i].name
    }
	// if(inputs[i].type.toLowerCase() == "file"){
	// 	console.log(inputs[i].files)
	// }
  }

  
  for (var i=0; i<inputs2.length; i++) {
    if (inputs2[i].type.toLowerCase() === "password" || inputs2[i].type.toLowerCase() === "text") {
      inputs2[i].value=inputs2[i].name
    }
  }
  
  for (var i=0; i<inputs3.length; i++) {
    if (inputs3[i].type.toLowerCase() === "password" || inputs3[i].type.toLowerCase() === "text") {
      inputs3[i].value=inputs3[i].name
    }
  }




