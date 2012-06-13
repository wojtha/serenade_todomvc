(function() {
  var Application, ApplicationController, Todo,
    __hasProp = Object.prototype.hasOwnProperty,
    __extends = function(child, parent) { for (var key in parent) { if (__hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor; child.__super__ = parent.prototype; return child; };

  Application = (function(_super) {

    __extends(Application, _super);

    function Application() {
      Application.__super__.constructor.apply(this, arguments);
    }

    Application.hasMany('todos', {
      as: (function() {
        return Todo;
      }),
      serialize: true
    });

    Application.localStorage = true;

    Application.property('doneTodos', {
      get: function() {
        return this.get('todos').filter(function(item) {
          return item.get('done');
        });
      },
      dependsOn: 'todos:done'
    });

    Application.property('incompleteTodos', {
      get: function() {
        return this.get('todos').filter(function(item) {
          return !item.get('done');
        });
      },
      dependsOn: 'todos:done'
    });

    Application.property('completedCount', {
      get: function() {
        return this.get('doneTodos').length;
      },
      format: function(val) {
        return val || "0";
      },
      dependsOn: 'doneTodos'
    });

    Application.property('incompleteCount', {
      get: function() {
        return this.get('incompleteTodos').length;
      },
      format: function(val) {
        return val || "0";
      },
      dependsOn: 'incompleteTodos'
    });

    Application.property('allCompleted', {
      get: function() {
        return this.get('incompleteCount') <= 0;
      },
      dependsOn: 'incompleteCount'
    });

    Application.prototype.setTodoDone = function(done) {
      return this.get('todos').forEach(function(todo) {
        return todo.set('done', done);
      });
    };

    return Application;

  })(Serenade.Model);

  Todo = (function(_super) {

    __extends(Todo, _super);

    function Todo() {
      Todo.__super__.constructor.apply(this, arguments);
    }

    Todo.property('done', {
      serialize: true
    });

    Todo.property('status', {
      dependsOn: 'done',
      get: function() {
        if (this.get('done')) {
          return 'done';
        } else {
          return 'active';
        }
      }
    });

    Todo.property('title', {
      serialize: true
    });

    Todo.prototype.toggleDone = function() {
      return this.set('done', !this.done);
    };

    return Todo;

  })(Serenade.Model);

  ApplicationController = (function() {

    function ApplicationController(model) {
      this.model = model;
    }

    ApplicationController.prototype.setTodoDone = function() {
      if (this.model.get('allCompleted')) {
        return this.model.setTodoDone(false);
      } else {
        return this.model.setTodoDone(true);
      }
    };

    ApplicationController.prototype.clear = function() {
      return this.model.set('todos', this.model.get('incompleteTodos'));
    };

    ApplicationController.prototype.setTitle = function(app, target) {
      return this.title = target.value;
    };

    ApplicationController.prototype.addNew = function() {
      if (this.title) {
        return this.model.get('todos').push({
          title: this.title
        });
      }
    };

    ApplicationController.prototype.toggleDone = function(todo) {
      return todo.toggleDone();
    };

    return ApplicationController;

  })();

  window.onload = function() {
    var element, script;
    script = document.getElementById("app");
    element = Serenade.view(script.innerText).render(Application.find(1), ApplicationController);
    return document.getElementById('todoapp').appendChild(element);
  };

}).call(this);
