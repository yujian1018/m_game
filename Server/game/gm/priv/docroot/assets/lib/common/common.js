var common = {
    //iframe自适应高度
    reinitIframe: function (id) {
        var iframe = document.getElementById(id);
        var bHeight = iframe.contentWindow.document.body.scrollHeight;
        var dHeight = iframe.contentWindow.document.documentElement.scrollHeight;
        var height = Math.max(bHeight, dHeight);
        if (height >= 500) {
            iframe.height = height;
        } else {
            iframe.height = 500;
        }
    },

    move_to_up: function (obj) {
        var objParentTR = $(obj).parent().parent();
        var prevTR = objParentTR.prev();
        if (prevTR.length > 0) {
            prevTR.insertAfter(objParentTR);
        }
    },

    move_to_down: function (obj) {
        var objParentTR = $(obj).parent().parent();
        var nextTR = objParentTR.next();
        if (nextTR.length > 0) {
            nextTR.insertBefore(objParentTR);
        }
    }
};



