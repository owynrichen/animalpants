function showFact(obj) {
    $(obj).find(".tc").css("display", 'none');
    $(obj).find(".tc.hide").css("display", 'table-cell');
}

function hideFact(obj) {
    $(obj).find(".tc").css("display", 'table-cell');
    $(obj).find(".tc.hide").css("display", 'none');
}

function showDrawing(obj) {
    $(obj).find(".real").css("display", "none");
    $(obj).find(".draw").css("display", "block");
}

function hideDrawing(obj) {
    $(obj).find(".real").css("display", "block");
    $(obj).find(".draw").css("display", "none");
}