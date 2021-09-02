layui.use(['form','jquery',"layer"],function() {
    var form = layui.form,
        $ = layui.jquery,
        layer = parent.layer === undefined ? layui.layer : top.layer;

    //非管理员登录屏蔽操作按钮
    if(localStorage.getItem("IS_ADMIN")==0){
        $(".save").remove();
    }

    //获取当前系统支付配置
    Common.invoke({
        url : request('/console/payConfig'),
        data : {},
        successMsg : false,
        errorMsg : "获取数据失败,请检查网络",
        success : function(result) {
            fillParameter(result.data);
        },
        error : function(result) {
        }

    });

    form.on("submit(walletConfig)",function(){
        var payConfig = {};
        payConfig.id = 10000;
        payConfig.maxTransferAmount = $(".maxTransferAmount").val();
        payConfig.maxRedpacktAmount = $(".maxRedpacktAmount").val();
        payConfig.maxRedpacktNumber = $(".maxRedpacktNumber").val();
        payConfig.maxWithdrawAmount = $(".maxWithdrawAmount").val();
        payConfig.maxRechargeAmount = $(".maxRechargeAmount").val();
        payConfig.maxCodePaymentAmount = $(".maxCodePaymentAmount").val();
        payConfig.maxCodeReceiptAmount = $(".maxCodeReceiptAmount").val();
        payConfig.dayMaxTransferAmount = $(".dayMaxTransferAmount").val();
        payConfig.dayMaxRedpacktAmount = $(".dayMaxRedpacktAmount").val();
        payConfig.dayMaxWithdrawAmount = $(".dayMaxWithdrawAmount").val();
        payConfig.dayMaxRechargeAmount = $(".dayMaxRechargeAmount").val();
        payConfig.dayMaxCodePayAmount = $(".dayMaxCodePayAmount").val();
        payConfig.dayMaxCodeReceiptAmount = $(".dayMaxCodeReceiptAmount").val();
        payConfig.isOpenManualPay = $(".isOpenManualPay").val();
        payConfig.isOpenCloudWallet = $(".isOpenCloudWallet").val();
        payConfig.isDefaultFreeze = $(".isDefaultFreeze").val();
        payConfig.myChangeWithdrawRate = $(".myChangeWithdrawRate").val();
        payConfig.newYopUserRechargeTime = $(".newYopUserRechargeTime").val();
        payConfig.newYopUserFirstRecharge = $(".newYopUserFirstRecharge").val();
        payConfig.consoleMaxRechargeAmount = $(".consoleMaxRechargeAmount").val();
        payConfig.consoleMaxCodePaymentAmount = $(".consoleMaxCodePaymentAmount").val();

        Common.invoke({
            url : request('/console/payConfig/set'),
            data : payConfig,
            successMsg : "系统配置修改成功",
            errorMsg : "修改系统配置失败,请检查网络",
            success : function(result) {

            },
            error : function(result) {

            }

        });
        return false;
    })

});

function fillParameter(data){
    //判断字段数据是否存在
    function nullData(data){
        if(data == '' || data == "undefined" || data==null){
            return "";
        }else{
            return data;
        }
    }
    // 数据回现
    $(".maxTransferAmount").val(data.maxTransferAmount);
    $(".maxRedpacktAmount").val(data.maxRedpacktAmount);
    $(".maxRedpacktNumber").val(data.maxRedpacktNumber);
    $(".maxWithdrawAmount").val(data.maxWithdrawAmount);
    $(".maxRechargeAmount").val(data.maxRechargeAmount);
    $(".maxCodePaymentAmount").val(data.maxCodePaymentAmount);
    $(".maxCodeReceiptAmount").val(data.maxCodeReceiptAmount);
    $(".dayMaxTransferAmount").val(data.dayMaxTransferAmount);
    $(".dayMaxRedpacktAmount").val(data.dayMaxRedpacktAmount);
    $(".dayMaxWithdrawAmount").val(data.dayMaxWithdrawAmount);
    $(".dayMaxRechargeAmount").val(data.dayMaxRechargeAmount);
    $(".dayMaxCodePayAmount").val(data.dayMaxCodePayAmount);
    $(".dayMaxCodeReceiptAmount").val(data.dayMaxCodeReceiptAmount);
    $(".isOpenManualPay").val(data.isOpenManualPay);
    $(".isOpenCloudWallet").val(data.isOpenCloudWallet);
    $(".isDefaultFreeze").val(data.isDefaultFreeze);
    $(".myChangeWithdrawRate").val(data.myChangeWithdrawRate);
    $(".newYopUserRechargeTime").val(data.newYopUserRechargeTime);
    $(".newYopUserFirstRecharge").val(data.newYopUserFirstRecharge);
    $(".consoleMaxRechargeAmount").val(data.consoleMaxRechargeAmount);
    $(".consoleMaxCodePaymentAmount").val(data.consoleMaxCodePaymentAmount);
    //重新渲染
    layui.form.render();
}