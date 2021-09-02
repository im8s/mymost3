$(function () {
layui.config({
    base: 'module/'
}).extend({
    treetable: 'treetable-lay/treetable'
}).use(['table', 'form', 'element', 'treetable'], function () {
    var $ = layui.jquery;
    var table = layui.table;
    var form = layui.form;
    var element = layui.element;
    var treetable = layui.treetable;

    // 渲染表格
    var renderTable = function () {
        layer.load(2);
        treetable.render({
            treeColIndex: 0,//设置在什么位置开张开树的
            treeSpid: -1,
            treeIdName: 'd_id',
            treePidName: 'd_pid',
            elem: '#table1',
            url: request("/department/list1")+"&companyId=2",
            treeDefaultClose: true,//默认不展开树
            treeLinkage: false,//默认不展开树
            page: false,
            cols: [[
                {field: 'name'},
                {field: 'sex'},
                {field: 'pid'},
                {templet: '#oper-col'}
            ]],
            done: function () {
                layer.closeAll('loading');
            }
        });
    };

    renderTable();

    $('#btn-expand').click(function () {
        treetable.expandAll('#table1');
    });

    $('#btn-fold').click(function () {
        treetable.foldAll('#table1');
    });

    $('#btn-refresh').click(function () {
        renderTable();
    });

});
})