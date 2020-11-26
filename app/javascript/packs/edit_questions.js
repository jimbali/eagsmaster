import $ from 'jquery'
import Handsontable from 'handsontable'
import 'bootstrap'
import bootbox from 'bootbox'
import quizTable from './edit_quiz'

export default class EditQuestions {
  #autosaveNotification = null

  afterChange(change, source) {
    if (source === 'loadData') return

    clearTimeout(this.autosaveNotification)

    const row = this.data[change[0][0]]
    const questionId = row['id']

    const confirmMessage = `
      Not all answers for this round have points assigned to them.
      Continue anyway?
    `

    this.editQuiz.refreshData().then(() => {
      if (change[0][1] == 'expired' && change[0][3] == true
                                    && !this.editQuiz.allIn(questionId)) {
        bootbox.confirm(
          confirmMessage, (proceed) => {
            this.handleConfirmation(proceed, questionId, row)
          }
        )
      } else {
        this.updateQuestion(questionId, row)
      }
    })
  }

  handleConfirmation(proceed, questionId, row) {
    if (proceed) {
      this.updateQuestion(questionId, row)
    } else {
      this.reopenQuestion(questionId)
    }
  }

  reopenQuestion(questionId) {
    const row = this.data.find((row) => row.id == questionId)
    row.expired = false
    this.hot.loadData(this.data)
  }

  updateQuestion(questionId, row) {
    fetch(
      this.baseUrl + '/' + questionId,
      {
        method: 'PATCH',
        headers: {
          'Content-Type': 'application/json',
          'X-CSRF-Token': this.token
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
      const questionsConsole = this.questionsConsole
      questionsConsole.text('Autosaved (1 cell)')

      this.autosaveNotification = setTimeout(function() {
        questionsConsole.text('Changes will be autosaved')
      }, 2000)
    })
  }

  beforeRemoveRow(index, amount, physicalRows, source) {
    for(let i = 0; i < physicalRows.length; i++) {
      const index = physicalRows[i]
      const id = this.data[index].id

      fetch(
        this.baseUrl + '/' + id,
        {
          method: 'DELETE',
          headers: {
            'Content-Type': 'application/json',
            'X-CSRF-Token': this.token
          }
        }
      )
      .then((response) => {
        const questionsConsole = this.questionsConsole
        questionsConsole.text('Autosaved (row deleted)')

        this.autosaveNotification = setTimeout(function() {
          questionsConsole.text('Changes will be autosaved')
        }, 2000)
      })
    }
  }

  constructor(editQuiz) {
    $(document).on('ready turbolinks:load', () => {
      const questionsContainer = $('#questions-root')
      if (!questionsContainer.length) return

      this.editQuiz = editQuiz
      this.questionsConsole = $('#questions-console')
      this.data = questionsContainer.data('quizJson')
      this.token = $('meta[name="csrf-token"]').attr('content')
      this.baseUrl = questionsContainer.data('baseUrl')
      this.hot = new Handsontable(questionsContainer[0], {
        data: this.data,
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
        afterChange: this.afterChange.bind(this),
        beforeRemoveRow: this.beforeRemoveRow.bind(this)
      })
    })
  }
}
