class Application extends Serenade.Model
  @hasMany 'todos', as: (-> Todo), serialize: true

  @property 'doneTodos',
    get: -> @todos.filter((item) -> item.done)
    dependsOn: 'todos:done'
  @property 'incompleteTodos',
    get: -> @todos.filter((item) -> not item.done)
    dependsOn: 'todos:done'
  @property 'completedCount',
    get: -> @doneTodos.length
    format: (val) -> val or "0"
    dependsOn: 'doneTodos'
  @property 'incompleteCount',
    get: -> @incompleteTodos.length
    format: (val) -> val or "0"
    dependsOn: 'incompleteTodos'
  @property 'allCompleted',
    get: -> @incompleteCount <= 0
    dependsOn: 'incompleteCount'

  setTodoDone: (done) ->
    @todos.forEach (todo) -> todo.done = done

class Todo extends Serenade.Model
  @property 'done', serialize: true
  @property 'status', dependsOn: 'done', get: -> if @done then 'done' else 'active'
  @property 'title', serialize: true

  toggleDone: -> @done = not @done

class ApplicationController
  constructor: (@app) ->
  setTodoDone: ->
    if @app.allCompleted
      @app.setTodoDone(false)
    else
      @app.setTodoDone(true)
  clear: ->
    @app.todos = @app.incompleteTodos
  setTitle: (target) ->
    @title = target.value
  addNew: ->
    @app.todos.push(title: @title) if @title
  toggleDone: (target, todo) -> todo.toggleDone()

window.onload = ->
  script = document.getElementById('app')
  element = Serenade.view(script.innerText).render(Application.find(1), ApplicationController)
  document.getElementById('todoapp').appendChild(element)
