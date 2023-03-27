// FUNCTIONS
autoRefreshTime = 600000;

setInterval(() => {
  clearArray();
  setTimeout(() => {
    getJSON();
    makeUL();
  }, 1000);
}, autoRefreshTime);

countDown();

function checkTime() {
  fetch('checkTime')
    .then(function (response) {
      return response.json();
    })
    .then(function (data) {
      const formAlert = document.querySelector('.form-alert');
      let timeFile = data.msg;
      formAlert.textContent = timeFile;
      console.log(timeFile);
    });
}

function getJSON() {
  fetch('fileDB')
    .then(function (response) {
      return response.json();
    })
    .then(function (data) {
      makeUL(data);
      //   appendData(data);
    })
    .catch(function (err) {
      console.log('error: ' + err);
    });
}

function makeUL(array) {
  array.sort((a, b) => (a.number < b.number ? 1 : -1));
  array.sort((a, b) => (a.line > b.line ? 1 : -1));
  // Create the list element:
  var list = document.createElement('ul');
  list.setAttribute('id', 'myUL');

  for (var i = 0; i < array.length; i++) {
    // Create the list item:
    var item = document.createElement('li');
    var x = document.createElement('a');

    // Set its contents:
    x.appendChild(
      document.createTextNode(
        array[i].line + ',' + array[i].number + ',' + array[i].mpn
      )
    );
    item.appendChild(x);
    // Add it to the list:
    list.appendChild(item);
  }
  myData.appendChild(list);
  // Finally, return the constructed list:
  return myData;
}
function myFunction() {
  var input, filter, ul, li, a, i, txtValue;
  input = document.getElementById('myInput');
  filter = input.value.toUpperCase();
  ul = document.getElementById('myUL');
  li = ul.getElementsByTagName('li');
  for (i = 0; i < li.length; i++) {
    a = li[i].getElementsByTagName('a')[0];
    txtValue = a.textContent || a.innerText;
    if (txtValue.toUpperCase().indexOf(filter) > -1) {
      li[i].style.display = '';
    } else {
      li[i].style.display = 'none';
    }
  }
}

function clearDBTime() {
  const element = document.getElementById('test1');
  if (element) {
    console.log(element);
    element.remove();
    setTimeout(console.log(element), 60000);
  }
}
function clearArray() {
  const element = document.getElementById('myUL');
  if (element) {
    console.log(element);
    element.remove();
  }
}
function autoRefresh() {
  window.location = window.location.href;
}
function countDown() {
  var countDownDate = new Date().getTime();
  // Update the count down every 1 second
  var x = setInterval(function () {
    // Get today's time
    var now = new Date().getTime();

    // Calculate the difference
    var distance = autoRefreshTime + (countDownDate - now);
    if (distance < 1) {
      countDownDate = new Date().getTime();
      var minutes = 0;
      var seconds = 0;
    } else {
      // Time calculations for minutes and seconds
      var minutes = Math.floor((distance % (1000 * 60 * 60)) / (1000 * 60));
      var seconds = Math.floor((distance % (1000 * 60)) / 1000);
    }
    // Display the result in the element with id="timer"
    document.getElementById('timer').innerHTML =
      minutes + 'm ' + seconds + 's ';
  }, 1000);
}
