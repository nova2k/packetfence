"use strict";

/*
 * The Users class defines the operations available from the controller.
 */
var Users = function() {
};

Users.prototype.get = function(options) {
    $.ajax({
        url: options.url
    })
        .always(options.always)
        .done(options.success)
        .fail(function(jqXHR) {
            var status_msg = getStatusMsg(jqXHR);
            showError(options.errorSibling, status_msg);
        });
};

Users.prototype.post = function(options) {
    $.ajax({
        url: options.url,
        type: 'POST',
        data: options.data
    })
        .done(options.success)
        .fail(function(jqXHR) {
            var status_msg = getStatusMsg(jqXHR);
            showError(options.errorSibling, status_msg);
        });
};

Users.prototype.toggleViolation = function(options) {
    var action = options.status? "open" : "close";
    var url = ['/node',
               action,
               options.name.substr(10)];
    $.ajax({ url: url.join('/') })
        .always(options.always)
        .done(options.success)
        .fail(options.error);
};

/*
 * The UserView class defines the DOM operations from the Web interface.
 */
var UserView = function(options) {
    this.users = options.users;
    this.disableToggleViolation = false;

    var read = $.proxy(this.readUser, this);
    options.parent.on('click', '[href*="user"][href$="/read"]', read);

    var update = $.proxy(this.updateUser, this);
    $('body').on('submit', '#modalUser form[name="modalUser"]', update);

    var delete_user = $.proxy(this.deleteUser, this);
    $('body').on('click', '#modalUser [href$="/delete"]', delete_user);

    var reset_password = $.proxy(this.resetPassword, this);
    $('body').on('click', '#modalUser #resetPassword', reset_password);

    var mail_password = $.proxy(this.mailPassword, this);
    $('body').on('click', '#modalUser #mailPassword', mail_password);

    var read_violations = $.proxy(this.readViolations, this);
    $('body').on('show', 'a[data-toggle="tab"][href="#userViolations"]', read_violations);

    var read_node = $.proxy(this.readNode, this);
    $('body').on('click', '#modalUser [href$="/read"]', read_node);

    var toggle_violation = $.proxy(this.toggleViolation, this);
    $('body').on('switch-change', '#modalUser .switch', toggle_violation);

    $('body').on('change', '#modalUser #ruleActions select[name$=type]', function(event) {
        /* Update the rule action fields when changing an action type */
        updateAction($(this));
    });

    $('body').on('admin.added', '#modalUser tr', function(event) {
        /* Update the rule action fields when adding an action */
        var tr = $(this);
        tr.find(':input').removeAttr('disabled');
        var type = tr.find('select[name$=type]').first();
        updateAction(type);
    });
    /* Update the advanced search form to the next page or resort the query*/
    var advanced_search_updater = $.proxy(this.advancedSearchUpdater, this);
    $('body').on('click', '[href*="#user/advanced_search"]', advanced_search_updater);

};

UserView.prototype.readUser = function(e) {
    e.preventDefault();

    var section = $('#section');
    var loader = section.prev('.loader');
    loader.show();
    section.fadeTo('fast', 0.5);
    this.users.get({
        url: $(e.target).attr('href'),
        always: function() {
            loader.hide();
            section.stop();
            section.fadeTo('fast', 1.0);
        },
        success: function(data) {
            $('#modalUser').remove();
            $('body').append(data);
            var modal = $("#modalUser");
            modal.find('.datepicker').datepicker({ autoclose: true });
            modal.find('#ruleActions tr:not(.hidden) select[name$=type]').each(function() {
                updateAction($(this),true);
            });
            modal.on('shown', function() {
                modal.find(':input:visible').first().focus();
                modal.find('[data-toggle="tooltip"]').tooltip({placement: 'top'});
            });
            modal.modal({ show: true });
        },
        errorSibling: section.find('h2').first()
    });
};

UserView.prototype.updateUser = function(e) {
    e.preventDefault();

    var modal = $('#modalUser');
    var form = modal.find('form').first();
    var valid = isFormValid(form);
    if (valid) {
        var modal_body = modal.find('.modal-body').first();
        resetAlert(modal_body);

        this.users.post({
            url: form.attr('action'),
            data: form.serialize(),
            success: function(data) {
                modal.modal('hide');
                modal.on('hidden', function() {
                    $(window).hashchange();
                });
            },
            errorSibling: modal_body.children().first()
        });
    }
};

UserView.prototype.deleteUser = function(e) {
    e.preventDefault();

    var modal = $('#modalUser');
    var modal_body = modal.find('.modal-body');
    var btn = $(e.target);
    var url = btn.attr('href');
    this.users.get({
        url: url,
        success: function(data) {
            modal.modal('hide');
            modal.on('hidden', function() {
                $(window).hashchange();
            });
        },
        errorSibling: modal_body.children().first()
    });
};

UserView.prototype.resetPassword = function(e) {
    e.preventDefault();

    var btn = $(e.target);
    var url = btn.attr('href');
    var password = $('#password');
    var password_control = password.closest('.control-group');
    var password2 = $('#password2');
    var password2_control = password2.closest('.control-group');
    var sibbling = $('#userPassword').children().first();
    var valid = true;

    if (isFormInputEmpty(password) || isFormInputEmpty(password2))
        valid = false;
    else {
        if (password.val() != password2.val()) {
            password_control.addClass('error');
            password2_control.addClass('error');
            valid = false;
        }
        else {
            password_control.removeClass('error');
            password2_control.removeClass('error');
        }
    }
    if (valid) {
        this.users.post({
            url: url,
            data: { password: password.val() },
            success: function(data) {
                showSuccess(password_control, data.status_msg);
            },
            errorSibling: password_control
        });
    }
};

UserView.prototype.mailPassword = function(e) {
    e.preventDefault();

    var btn = $(e.target);
    var url = btn.attr('href');
    var control = $('#userPassword .control-group').first();
    this.users.get({
        url: url,
        success: function(data) {
            showSuccess(control, data.status_msg);
        },
        errorSibling: control
    });
};

UserView.prototype.readViolations = function(e) {
    var btn = $(e.target);
    var target = $(btn.attr("href"));
    if (target.children().length == 0)
        target.load(btn.attr("data-href"), function() {
            target.find('.switch').bootstrapSwitch();
        });
    return true;
};

UserView.prototype.readNode = function(e) {
    e.preventDefault();

    var url = $(e.target).attr('href');
    var section = $('#section');
    var loader = section.prev('.loader');
    var modalUser = $("#modalUser");
    var modalUser_body = modalUser.find('.modal-body').first();
    loader.show();
    section.fadeTo('fast', 0.5);
    this.users.get({
        url: url,
        always: function() {
            loader.hide();
            section.stop();
            section.fadeTo('fast', 1.0);
        },
        success: function(data) {
            $('body').append(data);
            var modalNode = $("#modalNode");
            modalUser.one('hidden', function(e){
                modalNode.modal('show');
            });
            modalNode.one('hidden', function (e) {
                modalUser.modal('show');
            });
            modalUser.modal('hide');
        },
        errorSibling: modalUser_body.children().first()
    });
};

UserView.prototype.toggleViolation = function(e) {
    e.preventDefault();

    // Ignore event if it occurs while processing a toggling
    if (this.disableToggleViolation) return;
    this.disableToggleViolation = true;

    var that = this;
    var btn = $(e.target);
    var name = btn.find('input:checkbox').attr('name');
    var status = btn.bootstrapSwitch('status');
    var pane = $('#userViolations');
    resetAlert(pane.parent());
    this.users.toggleViolation({
        name: name,
        status: status,
        success: function(data) {
            showSuccess(pane.children().first(), data.status_msg);
            that.disableToggleViolation = false;
        },
        error: function(jqXHR) {
            var status_msg = getStatusMsg(jqXHR);
            showError(pane.children().first(), status_msg);
            // Restore switch state
            btn.bootstrapSwitch('setState', !status, true);
            that.disableToggleViolation = false;
        }
    });
};

UserView.prototype.advancedSearchUpdater = function(e) {
    e.preventDefault();
    var link = $(e.currentTarget);
    var form = $('#advancedSearch');
    var href = link.attr("href");
    if(href) {
        href = href.replace(/^.*#user\/advanced_search\//,'');
        var values = href.split("/");
        for(var i =0;i<values.length;i+=2) {
            var name = values[i];
            var value = values[i + 1];
            form.find('[name="' + name + '"]:not(:disabled)').val(value);
        }
        form.submit();
    }
    return false;
};
