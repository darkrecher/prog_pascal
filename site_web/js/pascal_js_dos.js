function get_app_filename() {
  var url = window.location.href
  var pos_url_params = url.indexOf("?")
  if (pos_url_params == -1) {
    return null
  }
  var params = url.slice(pos_url_params+1)
  params = params.split("&")
  // On prend que le premier param.
  // Osef, il est pas censé y'en avoir d'autres.
  var param = params[0]
  var name_and_val = param.split("=")
  if (name_and_val.length != 2) {
    return null
  }
  var name = name_and_val[0]
  if (name != "appfilename") {
    return null
  }
  return name_and_val[1]
}

// Oulala, le paramètre "prefix_url", c'est très moche. Tant pis !
function load_app(app_filename, prefix_url) {
  Dos(document.getElementById("jsdos"), {
      wdosboxUrl: prefix_url + "/js/js_dos/wdosbox.js"
  }).ready((fs, main) => {
    fs.extract(app_filename + ".zip").then(() => {
      main(["-c", app_filename + ".exe"])
    });
  });
}

glob_width = 800

function set_jsdos_size(width) {

  str_width = "width: " + glob_width + "px; height: " + parseInt(glob_width*0.75) +"px;"

  var node_dosbox_container = document.getElementsByClassName("dosbox-container")[0]
  node_dosbox_container.setAttribute("style", str_width)
  var node_jsdos = document.getElementById("jsdos")
  node_jsdos.setAttribute("style", str_width)
}

document.getElementById("zoom_in").onclick = function() {
  glob_width += 100
  set_jsdos_size(glob_width)
}

document.getElementById("zoom_out").onclick = function() {
  if (glob_width > 100) {
    glob_width -= 100
    set_jsdos_size(glob_width)
  }
}

