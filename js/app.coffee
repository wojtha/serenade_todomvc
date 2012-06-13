class Application extends Serenade.Model
  @hasMany 'todos', as: (-> Todo), serialize: true
  @localStorage = true

  @property 'doneTodos',
    get: -> @get('todos').filter((item) -> item.get('done'))
    dependsOn: 'todos:done'
  @property 'incompleteTodos',
    get: -> @get('todos').filter((item) -> not item.get('done'))
    dependsOn: 'todos:done'
  @property 'completedCount',
    get: -> @get('doneTodos').length
    format: (val) -> val or "0"
    dependsOn: 'doneTodos'
  @property 'incompleteCount',
    get: -> @get('incompleteTodos').length
    format: (val) -> val or "0"
    dependsOn: 'incompleteTodos'
  @property 'allCompleted',
    get: -> @get('incompleteCount') <= 0
    dependsOn: 'incompleteCount'

  setTodoDone: (done) ->
    @get('todos').forEach (todo) -> todo.set('done', done)

class Todo extends Serenade.Model
  @property 'done', serialize: true
  @property 'status', dependsOn: 'done', get: -> if @get('done') then 'done' else 'active'
  @property 'title', serialize: true

  toggleDone: -> @set('done', not @done)

class ApplicationController
  constructor: (@model) ->
  setTodoDone: ->
    if @model.get('allCompleted')
      @model.setTodoDone(false)
    else
      @model.setTodoDone(true)
  clear: ->
    @model.set('todos', @model.get('incompleteTodos'))
  setTitle: (app, target) ->
    @title = target.value
  addNew: ->
    @model.get('todos').push(title: @title) if @title
  toggleDone: (todo) -> todo.toggleDone()

window.onload = ->
  script = document.getElementById("app")
  element = Serenade.view(script.innerText).render(Application.find(1), ApplicationController)
  document.getElementById('todoapp').appendChild(element)
