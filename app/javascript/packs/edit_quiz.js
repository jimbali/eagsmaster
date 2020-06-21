import Handsontable from 'handsontable'

const afterChange = (change, source) => {
  if (source === 'loadData') return

  clearTimeout(autosaveNotification)

  const row = data[change[0][0]]

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
    return response.json()
  })
  .then((newData) => {
    quizConsole.innerText  = 'Autosaved (' + change.length + ' ' + 'cell' + (change.length > 1 ? 's' : '') + ')'
    autosaveNotification = setTimeout(function() {
      quizConsole.innerText = 'Changes will be autosaved'
    }, 2000)
    data = newData
    hot.loadData(newData)
  })
}

const quizConsole = document.getElementById('quiz-console')
const quizContainer = document.getElementById('quiz-root')
let data = JSON.parse(quizContainer.dataset.progressJson)
let autosaveNotification
const token = document.querySelector('meta[name="csrf-token"]').content
const updateProgressUrl = quizContainer.dataset.updateProgressUrl
const hot = new Handsontable(quizContainer, {
  data: data,
  rowHeaders: false,
  colHeaders: JSON.parse(quizContainer.dataset.columnHeaders),
  columns: JSON.parse(quizContainer.dataset.columnData),
  filters: true,
  dropdownMenu: true,
  licenseKey: 'non-commercial-and-evaluation',
  contextMenu: ['remove_row'],
  manualColumnResize: true,
  afterChange: afterChange
})
