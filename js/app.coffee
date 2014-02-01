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

class Persistence
  @store: (key, value) ->
    localStorage.setItem(key, value)
  @retrieve: (key) ->
    value = localStorage.getItem(key)
    JSON.parse(value) if value

window.onload = ->
  app_id = 1
  localData = Persistence.retrieve("SerenadeTodoApp#{app_id}")
  todoApp = if localData then new Application(localData) else new Application.find(app_id)
  todoApp.changed.bind -> Persistence.store("SerenadeTodoApp#{@id}", @)
  script = document.getElementById('app')
  element = Serenade.view(script.innerText).render(todoApp, ApplicationController)
  document.getElementById('todoapp').appendChild(element)
