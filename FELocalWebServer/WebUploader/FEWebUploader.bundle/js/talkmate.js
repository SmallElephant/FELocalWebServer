$(document).ready(function() {
    var acceptFileTypes=/^audio\/(mp3)$/i;
    var maxSize=5*1024*1024;
    $(".upload-progress").css("display", "none");
    $("#upload-container").click(function(event) {
        $("#fileupload").click();
    });

    $("#fileupload").click(function(event) {
        event.stopPropagation();
    });

    $("#fileupload").fileupload({
        dropZone: $(document),
        pasteZone: null,
        autoUpload: false,
        sequentialUploads: true,
        singleFileUploads: true,
        url: 'upload',
        type: 'POST',
        dataType: 'json',

        start: function(e) {
            $(".upload-progress").css("display", "block");
            $(".upload-container").css("background-image", "url(../images/uploading.png)");
        },

        stop: function(e) {
            $(".upload-progress").css("display", "none");
            $(".upload-container").css("background-image", "url(../images/upload_normal.png)");
        },

        add: function(e, data) {
            console.log('fileupload---add');
            var uploadErrors = [];
//            uploadErrors.push('只支持MP3格式');
//            if (data.originalFiles[0]['type'].length && !acceptFileTypes.test(data.originalFiles[0]['type'])) {
//                uploadErrors.push('只支持MP3格式');
//            }
            if (data.originalFiles[0]['size'] > maxSize) {
                uploadErrors.push('文件大小不能超过5M');
            }
            if (uploadErrors.length > 0) {
                $.dialog({
                    title: '提示',
                    content: uploadErrors.join("\n"),
                });
            } else {
                var jqXHR = data.submit(); 
                $(".upload-cancel").click(function() {
                    jqXHR.abort();
                    $(".upload-progress").css("display", "none");
                });
            }
        },

        progress: function(e, data) {
            var progress = parseInt(data.loaded / data.total * 100, 10);
            console.log("已加载:" + data.loaded + "---上传大小:" + data.total + "---进度:" + progress);
            $(".upload-progress-bar").css("width", progress + "%");
            $(".upload-progress-rate").text(progress + "%");
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