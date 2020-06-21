var quizConsole = document.getElementById('quiz-console');
var quizContainer = document.getElementById('quiz-root');
var data2 = JSON.parse(quizContainer.dataset.progressJson);
var autosaveNotification2;
var token = document.querySelector('meta[name="csrf-token"]').content;
var updateProgressUrl = quizContainer.dataset.updateProgressUrl;
hot2 = new Handsontable(quizContainer, {
  data: data2,
  rowHeaders: false,
  colHeaders: JSON.parse(quizContainer.dataset.columnHeaders),
  columns: JSON.parse(quizContainer.dataset.columnData),
  filters: true,
  dropdownMenu: true,
  licenseKey: 'non-commercial-and-evaluation',
  contextMenu: ['remove_row'],
  manualColumnResize: true,
  afterChange: function (change, source) {
    if (source === 'loadData') return;

    clearTimeout(autosaveNotification2);

    var row = data2[change[0][0]];

    fetch(
      updateProgressUrl,
      {
        method: 'POST',
        headers: {
          'Content-Type': 'application/json',
          'X-CSRF-Token': token
        },
        body: JSON.stringify({ row: row })
      }
    )
    .then((response) => {
      return response.json();
    })
    .then((newData) => {
      quizConsole.innerText  = 'Autosaved (' + change.length + ' ' + 'cell' + (change.length > 1 ? 's' : '') + ')';
      autosaveNotification2 = setTimeout(function() {
        quizConsole.innerText ='Changes will be autosaved';
      }, 2000);
      data2 = newData;
      hot2.loadData(newData);
    });
  }
});
