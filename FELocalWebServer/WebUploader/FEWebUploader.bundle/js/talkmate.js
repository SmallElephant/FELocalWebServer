var _path = null;

$(document).ready(function() {
                  
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
      console.log("开始");
      $(".uploading").text("开始");
    },
    
    stop: function(e) {
      // $(".uploading").hide();
      console.log("结束");
      $(".uploading").text("结束");
    },
    
     add: function(e, data) {
       console.log('fileupload---add');
       var file = data.files[0];
       data.formData = {
         path: _path
       };
//       data.context = $(tmpl("template-uploads", {
//         path: _path + file.name
//       })).appendTo("#uploads");
//       var jqXHR = data.submit();
       data.submit();
//       data.context.find("button").click(function(event) {
//         jqXHR.abort();
//       });
     },
    
    progress: function(e, data) {
      var progress = parseInt(data.loaded / data.total * 100, 10);
      console.log("已加载:"+data.loaded+"---上传大小:"+data.total+"---进度:"+progress);
      $(".uploading").text(progress + "%");
      // data.context.find(".progress-bar").css("width", progress + "%");
    },
    
    done: function(e, data) {
     console.log("已完成");
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
