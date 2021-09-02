$(function () {
    var descId = sessionStorage.getItem("descId");
    var data={
        "id":descId
    }
    $.ajax({
        type:"POST",
        url:request('/console/getOfficialInfo'),
        dataType:"json",
        data:data,
        contentType : 'application/x-www-form-urlencoded; charset=UTF-8',
        async:false,
        traditional: true,
        success : function(result) {
            var data = result.data;
            console.log(result)
            if (result.resultCode != 1){
                layer.msg(result.resultMsg);
            }else {
                $("#telephone").val(Common.filterHtmlData(data.telephone));
                $("#companyName").val(Common.filterHtmlData(data.companyName));
                $("#companyBusinessLicense").val(Common.filterHtmlData(data.companyBusinessLicense));
                $("#adminName").val(Common.filterHtmlData(data.adminName));
                $("#adminID").val(Common.filterHtmlData(data.adminID));
                $("#desc").val(Common.filterHtmlData(data.desc));
                $("#id").val(Common.filterHtmlData(data.id));
                $("#feedback").val(Common.filterHtmlData(data.feedback));
                $("#adminTelephone").val(Common.filterHtmlData(data.adminTelephone));
                $("#industryImg").attr('src',data.industryImg);
                $("#verify").val(Common.filterHtmlData(data.verify));


                if (data.companyType === 1){
                    $("#companyType").val("企业");
                }else{
                    $("#companyType").val("个体工商户");
                }

                $("#country").append("<option value=''>"+Common.filterHtmlData(data.country)+"</option>");
                $("#province").append("<option value=''>"+Common.filterHtmlData(data.province)+"</option>");
                $("#city").append("<option value=''>"+Common.filterHtmlData(data.city)+"</option>");
                layui.form.render();
            }
        },
        error : function(result) {
            layer.msg(result.resultMsg);
        }
    })

    $("#shiku-sub").click(function () {
        var verify = Common.getValueForElement("#verify");
        var feedback = Common.getValueForElement("#feedback");
        var id = Common.getValueForElement("#id");
        var data1 = {
            "feedback":feedback,
            "verify":verify,
            "id":id
        }
        $.ajax({
            type:"POST",
            url:request('/console/updateOfficialInfo'),
            dataType:"json",
            data:data1,
            async:false,
            success : function(result) {
                if (result.resultCode != 1) {
                    layer.msg(result.resultMsg);
                    return false;
                }
            },
            error : function(result) {
                layer.msg(result.resultMsg);
            }
        })
    })
})
