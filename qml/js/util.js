.pragma library

/* strip var from the result formula to present */
function filterVariables(text) {
    var re0 = /·/g;
    var re1 = /π/g;
    var re2 = /√/g;
    var re3 = /φ/g;
    // log is ln natural e in exprtk
    var re6 = /ln/g;
    //var re7 = /^/g;
    var newtxt = text.replace(re0, "*")
    newtxt = newtxt.replace(re1, "pi")
    newtxt = newtxt.replace(re2, "sqrt")
    newtxt = newtxt.replace(re3, "phi")
    newtxt = newtxt.replace(re6, "log")
    //newtxt = newtxt.replace(re7, "**")
    //console.log(newtxt)
    return newtxt
}
