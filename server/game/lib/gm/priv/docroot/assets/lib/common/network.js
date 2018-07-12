/**
 * Created by yujian on 17-5-17.
 */
var network = {
    ajax: function (url, cb) {
        network.connect(url, 'GET', null, cb);
    },
    post: function (url, arg, cb) {
        network.connect(url, 'POST', arg, cb);
    },
    connect: function (url, method, arg, cb) {
        $("#error_bg").show();
        $("#loading").show();
        $.ajax({
            url: url,
            dataType: "json",
            async: false,
            method: method,
            data: arg,
            error: function () {
                $("#error_bg").hide();
                $("#loading").hide();
                console.log("链接服务器失败，请稍后重试！");
            },
            success: function (data) {
                $("#error_bg").hide();
                $("#loading").hide();
                if (data.code == 200) {
                    cb(data);
                } else if (data.code == 10) {
                     window.location.href = "/login.html";
                } else if (data.code == 106) {
                    alert("玩家在线！");
                     tab_tpl.form_cancel();
                } else if (data.location != null) {
                    window.location.href = data.location;
                }
                else {
                    alert("错误码：" + data.code + "\n错误信息：" + data.msg);
                }
            }
        })
    },

    post_file: function (url, form_data, preview_bg, cbfun, failfun) {
        $.ajax({
            url: url,
            type: "POST", // 上传文件要用POST
            dataType: "json",
            processData: false,  // 注意：不要 process data
            contentType: false,  // 注意：不设置 contentType
            timeout: 1000 * 60 * 3,
            data: form_data,
            xhr: function () { //这是关键 获取原生的xhr对象 做以前做的所有事情
                var xhr = jQuery.ajaxSettings.xhr();
                xhr.upload.onprogress = function (ev) {
                    if (ev.lengthComputable) {
                        var percent = 100 - 100 * ev.loaded / ev.total;
                        $(preview_bg).height = percent + "%";
                    }
                };
                return xhr;
            },
            success: function (data) {
                if (data.code == 200) {
                    cbfun(data);
                } else {
                    alert("错误信息：" + err_code[data.code] + "\n 额外信息：" + data.msg + "..." + data.code);
                }
            },
            fail: function (msg) {
                failfun(msg);
            }
        });
    }

    // var xhr = new XMLHttpRequest();
    // xhr.open("GET", "/api/account_sproto/account_login?account_name=" + account + "&account_pwd=" + password, true);
    // // xhr.overrideMimeType("application/octet-stream");
    // // xhr.setRequestHeader('Content-Type', 'application/x-www-form-urlencoded');
    // // xhr.send(post_data);
    // xhr.send(null);
    // xhr.onreadystatechange = function () {
    //     console.log(xhr);
    //     if (xhr.readyState == 4 && xhr.status == 200) {
    //         console.log("response: " + xhr.responseText);
    //     }
    // };
};