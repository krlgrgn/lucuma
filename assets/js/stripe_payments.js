import $ from "jquery"

// Submit the form with the token ID.
function stripeTokenHandler(token) {
  // Insert the token ID into the form so it gets submitted to the server
  var form = document.getElementById('payment-form');
  var hiddenInput = document.createElement('input');
  hiddenInput.setAttribute('type', 'hidden');
  hiddenInput.setAttribute('name', 'stripeToken');
  hiddenInput.setAttribute('value', token.id);
  form.appendChild(hiddenInput);

  if (document.querySelectorAll("[data-phx-view='Live.RegistrationView']").length > 0) {
    $('#sub_submit_btn').click();
  } else {
    form.submit()
  }
}

// Custom styling can be passed to options when creating an Element.
// (Note that this demo uses a wider set of styles than the guide below.)
var style = {
  base: {
    color: '#32325d',
    // fontFamily: '"Helvetica Neue", Helvetica, sans-serif',
    fontSmoothing: 'antialiased',
    fontSize: '16px',
    lineHeight: '1.429',
    '::placeholder': {
      color: '#aab7c4'
    }
  },
  invalid: {
    color: '#fa755a',
    iconColor: '#fa755a'
  }
};

var stripify = function() {
  var payment_form = document.getElementById('payment-form')
  if (payment_form == null) { return false }

  var stripe = Stripe(payment_form.dataset.stripePublicKey);

  // Create an instance of Elements.
  var elements = stripe.elements();

  // Create an instance of the card Element.
  var element = elements.create("cardNumber", {
    classes: {
      base: "form-control",
      invalid: "is-invalid"
    },
    style: style
  });

  element.mount("#card-number");

  // Handle real-time validation errors from the card Element.
  element.on('change', function(event) {
    var displayError = document.getElementById('card-number-errors');
    if (event.error) {
      displayError.textContent = event.error.message;
    } else {
      displayError.textContent = '';
    }
  });

  // Create an instance of the expiry Element.
  var element = elements.create("cardExpiry", {
    classes: {
      base: "form-control",
      invalid: "is-invalid"
    },
    style: style
  });

  element.mount("#card-expiry");

  // Handle real-time validation errors from the card Element.
  element.on('change', function(event) {
    var displayError = document.getElementById('card-expiry-errors');
    if (event.error) {
      displayError.textContent = event.error.message;
    } else {
      displayError.textContent = '';
    }
  });

  // Create an instance of the cvc Element.
  var element = elements.create("cardCvc", {
    classes: {
      base: "form-control",
      invalid: "is-invalid"
    },
    style: style
  });

  element.mount("#card-cvc");

  // Handle real-time validation errors from the card Element.
  element.on('change', function(event) {
    var displayError = document.getElementById('card-cvc-errors');
    if (event.error) {
      displayError.textContent = event.error.message;
    } else {
      displayError.textContent = '';
    }
  });

  var form = document.getElementById('payment-form');
  var submitBtn = document.getElementById('subscribe-button');

  var handlePaymentForm = function(e){
    e.preventDefault();

    if (submitBtn) {
      submitBtn.setAttribute('disabled', 'disabled');
      submitBtn.setAttribute('text', 'Subscribing...');
    }

    Array.prototype.forEach.call(
      form.querySelectorAll(
        "input[type='text'], input[type='email'], input[type='tel']"
      ),
      function(input) {
        input.setAttribute('disabled', 'disabled');
      }
    );

    stripe.createToken(element).then(function(result) {
      if (result.error) {
        // Inform the user if there was an error.
        var errorElement = document.getElementById('card-errors');
        errorElement.textContent = result.error.message;
        document.getElementById("sub_submit_btn").removeAttribute("disabled");
        Array.prototype.forEach.call(
          form.querySelectorAll(
            "input[type='text'], input[type='email'], input[type='tel']"
          ),
          function(input) {
            input.removeAttribute('disabled');
          }
        );
      } else {
        console.log("stripe token reveived.")
        // Send the token to your server.
        stripeTokenHandler(result.token);
      }
    });
  }


  // Handle form submission.
  if (document.querySelectorAll("[data-phx-view='Live.RegistrationView']").length > 0) {
    submitBtn.addEventListener('click', handlePaymentForm);
  } else {
    form.addEventListener('submit', handlePaymentForm);
  }
}

$(document).ready(function(e) {
  if (document.querySelectorAll("[data-phx-view='Live.RegistrationView']").length < 1) {
    stripify();
  }
});

$(document).on("phx:update", function(e) {
  if (document.getElementsByClassName('ElementsApp').length < 1) {
    stripify();
  }
});

