function show (id, mice) {
    var uid, mouse;

    uid = id + "-" + "hide";
    document.getElementById(uid).style.display = "inline";

    uid = id + "-" + "show";
    document.getElementById(uid).style.display = "none";

    for ( mouse=1; mouse<=mice; mouse++) {
      uid = id + "-" + mouse;
      document.getElementById(uid).style.display = "table-row";
    }
}

function hide (id, mice) {
    var uid, mouse;

    uid = id + "-" + "show";
    document.getElementById(uid).style.display = "inline";

    uid = id + "-" + "hide";
    document.getElementById(uid).style.display = "none";

    for ( mouse=1; mouse<=mice; mouse++) {
      uid = id + "-" + mouse;
      document.getElementById(uid).style.display = "none";
    }
}

function show_all(pattern) {
    var divs = document.getElementsByName('cage_row');
    var i,id;

    show_all_other("hide");
    hide_all_other("show");

    for (i=0;i<divs.length;i++) {
        if (divs[i].id.match(pattern)) {
           id = divs[i].id;
           document.getElementById(id).style.display="table-row";
        }
    }
}

function hide_all(pattern) {
    var divs = document.getElementsByName('cage_row');
    var i,id;

    show_all_other("show");
    hide_all_other("hide");

    for (i=0;i<divs.length;i++) {
        if (divs[i].id.match(pattern)) {
           id = divs[i].id;
           document.getElementById(id).style.display="none";
        }
    }
}

function show_all_other(pattern) {
    var divs = document.getElementsByName('toggle');
    var i,id;

    for (i=0;i<divs.length;i++) {
        if (divs[i].id.match(pattern)) {
           id = divs[i].id;
           document.getElementById(id).style.display="inline";
        }
    }
}

function hide_all_other(pattern) {
    var divs = document.getElementsByName('toggle');
    var i,id;

    for (i=0;i<divs.length;i++) {
        if (divs[i].id.match(pattern)) {
           id = divs[i].id;
           document.getElementById(id).style.display="none";
        }
    }
}

function checkAll(field) {
  if (field.checkall.checked == true ) {
     for (i = 0; i < field.mouse_select.length; i++) {
         field.mouse_select[i].checked = true;
     }
  }
  else {
     for (i = 0; i < field.mouse_select.length; i++) {
         field.mouse_select[i].checked = false;
     }
  }
}

function checkAllcages(field) {
  if (field.checkallcages.checked == true ) {
     for (i = 0; i < field.cage_select.length; i++) {
         field.cage_select[i].checked = true;
     }
  }
  else {
     for (i = 0; i < field.cage_select.length; i++) {
         field.cage_select[i].checked = false;
     }
  }
}


function checkAll2(field) {
  if (field.checkall2.checked == true ) {
     for (i = 0; i < field.mouse_select.length; i++) {
         field.mouse_select[i].checked = true;
     }
  }
  else {
     for (i = 0; i < field.mouse_select.length; i++) {
         field.mouse_select[i].checked = false;
     }
  }
}


function checkAll3(action_field, target_field) {
  if (action_field.checked == true ) {
     for (i = 0; i < target_field.length; i++) {
         target_field[i].checked = true;
     }
  }
  else {
     for (i = 0; i < target_field.length; i++) {
         target_field[i].checked = false;
     }
  }
}

function checkAll4(action_field, target_field, pattern) {
  if (action_field.checked == true ) {
     for (i = 0; i < target_field.length; i++) {
         if (target_field[i].id.match(pattern)) {
               target_field[i].checked = true;
         }
     }
  }
  else {
     for (i = 0; i < target_field.length; i++) {
         if (target_field[i].id.match(pattern)) {
               target_field[i].checked = false;
         }
     }
  }
}

function set_cage(selector, pattern) {
  var f1 = document.myform;
  var cage_selection = selector.value;

  for (i = 0; i < f1.elements.length; i++) {
      if (f1.elements[i].id.match(pattern)) {
         f1.elements[i].value = cage_selection;
      }
  }
}


function openCalenderWindow (Address, Width, Height, Left, Top, Scrollbars) {
  CalendarWindow = window.open(Address, "CalendarWindow", "width=" + Width + ",height=" + Height + ", left= " + Left + ", top=" + Top + ", scrollbars=" + Scrollbars);
  CalendarWindow.focus();
}

function set_input_focus() {
    document.f.scan.focus();
}
