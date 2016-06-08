var _path = null;

$(document).ready(function() {
  
  // Workaround Firefox and IE not showing file selection dialog when clicking on "upload-file" <button>
  // Making it a <div> instead also works but then it the button doesn't work anymore with tab selection or accessibility
  $("#upload-container").click(function(event) {
    $("#fileupload").click();
  });
  
  // Prevent event bubbling when using workaround above
  $("#fileupload").click(function(event) {
    event.stopPropagation();
  });
  
  $("#fileupload").fileupload({
    dropZone: $(document),
    pasteZone: null,
    autoUpload: true,
    sequentialUploads: true,
    // limitConcurrentUploads: 2,
    // forceIframeTransport: true,
    
    url: 'upload',
    type: 'POST',
    dataType: 'json',
    
    start: function(e) {
      // $(".uploading").show();
      $(".uploading").text("开始");
    },
    
    stop: function(e) {
      // $(".uploading").hide();
      $(".uploading").text("取消");
    },
    
    // add: function(e, data) {
    //   var file = data.files[0];
    //   data.formData = {
    //     path: _path
    //   };
    //   data.context = $(tmpl("template-uploads", {
    //     path: _path + file.name
    //   })).appendTo("#uploads");
    //   var jqXHR = data.submit();
    //   data.context.find("button").click(function(event) {
    //     jqXHR.abort();
    //   });
    // },
    
    progress: function(e, data) {
      var progress = parseInt(data.loaded / data.total * 100, 10);
      $(".uploading").text(progress + "%");
      // data.context.find(".progress-bar").css("width", progress + "%");
    },
    
    done: function(e, data) {
      $(".uploading").text("已完成");
    }
    
    // fail: function(e, data) {
    //   var file = data.files[0];
    //   if (data.errorThrown != "abort") {
    //     _showError("Failed uploading \"" + file.name + "\" to \"" + _path + "\"", data.textStatus, data.errorThrown);
    //   }
    // },
    
    // always: function(e, data) {
    //   data.context.remove();
    // }
    
  });
  
});
