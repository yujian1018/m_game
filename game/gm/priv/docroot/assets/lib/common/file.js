/**
 * Created by yujian on 17-5-17.
 */
var file = {
    export_excel: function () {
        var valueTr = "";
        $("#table_field tr th").each(function () {
            valueTr += $(this).text() + ",";
        });

        var tableTr = "";
        var tb = document.getElementById("table_list");
        var rows = tb.rows;
        for (var i = 0; i < rows.length; i++) {
            valueTr += "\n";
            for (var j = 0; j < rows[i].cells.length; j++) {
                var cell = rows[i].cells[j];
                valueTr += cell.innerHTML + ",";
            }
        }
        var str = valueTr;
        str = encodeURIComponent(str);
        var export_link = document.getElementById("export_excel");
        export_link.href = "data:text/csv;charset=utf-8,\ufeff" + str;

        export_link.download = config.get_tab_name() + ".csv";
        export_link.click();

    },

    load: function (this_imgs, input_img, preview_img, preview_bg) {
        $(preview_bg).attr("class", "");
        var img_input = this_imgs.files[0];
        if (img_input) {
            var max_size = 200 * 1024;
            if (!/\/(?:jpeg|jpg|png)/i.test(img_input.type)) return alert("只能上传jpg,png格式");
            var reader = new FileReader();
            reader.onload = function (e) {
                var img = new Image();
                var result = e.target.result;
                // 如果图片小于 200kb，不压缩
                if (e.total <= max_size) {
                    $(preview_img).attr('src', e.target.result);
                    $(preview_bg).addClass("img-bg-upload");
                    file.file_upload(input_img, e.target.result, preview_bg);
                } else {
                    img.src = result;
                    img.onload = function () {
                        var compressedDataUrl = file.compress(img, img_input.type);
                        $(preview_img).attr('src', compressedDataUrl);
                        img = null;
                        $(preview_bg).addClass("img-bg-upload");
                        file.file_upload(input_img, compressedDataUrl, preview_bg);
                    }
                }
            };
            reader.readAsDataURL(img_input);


        }
    },
    load_file: function (this_file) {
        var files = document.getElementById(this_file);
        var file = files.files[0];
        console.log(file);
        // try sending
        var reader = new FileReader();

        reader.onloadstart = function () {
            // 这个事件在读取开始时触发
            console.log("onloadstart");
            console.log(file.size);
        };
        reader.onprogress = function (p) {
            // 这个事件在读取进行中定时触发
            console.log("onprogress");
            console.log(p.loaded);
        };

        reader.onload = function () {
            // 这个事件在读取成功结束后触发
            console.log("load complete");
        };

        reader.onloadend = function () {
            // 这个事件在读取结束后，无论成功或者失败都会触发
            if (reader.error) {
                console.log(reader.error);
            } else {
                console.log(file.size);
                // 构造 XMLHttpRequest 对象，发送文件 Binary 数据
                var post_data = new FormData();
                post_data.append("file", Base64.encode(reader.result));
                var xhr = new XMLHttpRequest();
                xhr.open(/* method */ "POST",
                    /* target url */ "/api/file_sproto/upload_cvs?fileName=" + file.name
                    /*, async, default to true */);
                xhr.overrideMimeType("application/octet-stream");
                xhr.send(post_data);
                xhr.onreadystatechange = function () {
                    if (xhr.readyState == 4) {
                        if (xhr.status == 200) {
                            console.log("upload complete");
                            console.log("response: " + xhr.responseText);
                        }
                    }
                }
            }
        };
        reader.readAsBinaryString(file);
    },

    compress: function (img, fileType) {
        var canvas = document.createElement("canvas");
        var ctx = canvas.getContext('2d');

        var width = 132;
        var height = 132;

        canvas.width = width;
        canvas.height = height;

        ctx.fillStyle = "#fff";
        ctx.fillRect(0, 0, canvas.width, canvas.height);
        ctx.drawImage(img, 0, 0, width, height);

        // 压缩
        var base64data = canvas.toDataURL(fileType, 0.75);

        // var initSize = img.src.length;
        // console.log('压缩前：', initSize);
        // console.log('压缩后：', base64data.length);
        // console.log('压缩率：', 100 * (initSize - base64data.length) / initSize, "%");

        canvas = ctx = null;

        return base64data;
    },

    file_upload: function (input_img, compressedDataUrl, preview_bg) {
        var post_data = new FormData();
        post_data.append("img", compressedDataUrl);
        network.post_file("/api/file_sproto/upload", post_data, preview_bg,
            function (data) {
                $(preview_bg).addClass("img-bg-upload-suc");
                $(preview_bg).html("上传成功");
                $(input_img).attr("value", data.url);
            },
            function (data) {
                $(preview_bg).addClass("img-bg-upload-fail");
                $(preview_bg).html("上传失败");
            });

    }
};