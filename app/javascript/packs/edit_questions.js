import $ from 'jquery'
import Handsontable from 'handsontable'
import 'bootstrap'
import bootbox from 'bootbox'

const allIn = (questionId) => {
  const column = 'question' + questionId + 'Points'
  const data = $('#quiz-root').data('progressJson')
  return data.every((row) => {
    return row[column] != null
  })
}

const afterChange = (change, source) => {
  if (source === 'loadData') return

  clearTimeout(autosaveNotification)

  const row = data[change[0][0]]
  const questionId = row['id']

  const confirmMessage = `
    Not all answers for this round have points assigned to them.
    Continue anyway?
  `

  if (change[0][1] == 'expired' && change[0][3] == true && !allIn(questionId)) {
    bootbox.confirm(
      confirmMessage, (proceed) => handleConfirmation(proceed, questionId, row)
    )
  } else {
    updateQuestion(questionId, row)
  }
}

const handleConfirmation = (proceed, questionId, row) => {
  if (proceed) {
    updateQuestion(questionId, row)
  } else {
    reopenQuestion(questionId)
  }
}

const reopenQuestion = (questionId) => {
  const row = data.find((row) => row.id == questionId)
  row.expired = false
  hot.loadData(data)
}

const updateQuestion = (questionId, row) => {
  fetch(
    baseUrl + '/' + questionId,
    {
      method: 'PATCH',
      headers: {
        'Content-Type': 'application/json',
        'X-CSRF-Token': token
      },
      body: JSON.stringify(
        { question: { title: row.title, expired: row.expired } }
      )
    }
  )
  .then((response) => {
    return response.json()
  })
  .then((data) => {
    questionsConsole.text('Autosaved (1 cell)')

    autosaveNotification = setTimeout(function() {
      questionsConsole.text('Changes will be autosaved')
    }, 2000)
  })
}

const beforeRemoveRow = (index, amount, physicalRows, source) => {
  for(let i = 0; i < physicalRows.length; i++) {
    const index = physicalRows[i]
    const id = data[index].id

    fetch(
      baseUrl + '/' + id,
      {
        method: 'DELETE',
        headers: {
          'Content-Type': 'application/json',
          'X-CSRF-Token': token
        }
      }
    )
    .then((response) => {
      questionsConsole.text('Autosaved (row deleted)')
      autosaveNotification = setTimeout(function() {
        questionsConsole.text('Changes will be autosaved')
      }, 2000)
    })
  }
}

let autosaveNotification
const questionsConsole = $('#questions-console')
const questionsContainer = $('#questions-root')
const data = questionsContainer.data('quizJson')
const token = $('meta[name="csrf-token"]').attr('content')
const baseUrl = questionsContainer.data('baseUrl')
const hot = new Handsontable(questionsContainer[0], {
  data: data,
  rowHeaders: false,
  colHeaders: ['Title', 'Finished answering?'],
  columns: [
    { data: 'title' },
    { data: 'expired', type: 'checkbox' }
  ],
  filters: true,
  dropdownMenu: true,
  licenseKey: 'non-commercial-and-evaluation',
  contextMenu: ['remove_row'],
  afterChange: afterChange,
  beforeRemoveRow: beforeRemoveRow
})
