nonCalculatedLimit = ""
nonCalculatedLimitOutput = ""
resultLimit = ""
resultLimitSimp = ""
resultOutput = ""
timeLimit = 0.0
limitErrorMessage = 'Error: limit not calculated'

numerApprox = False

def mapexpr(expr,func):
    if isinstance(expr,Add):
        return Add(*map(func,expr.args))
    else:
        return func(expr)

def fixUnicodeText(text):
    text = text.replace(u"⎽","_")
    text = text.replace(u"ℯ","e")
    text = text.replace(u"ⅈ","i")
    return text

def calculate_Limit(expression,variable,point,direction,\
                    flagPortrait,showLimit,showTime,numerApprox,numDigText,\
                    simplifyResult,outputResult):
    global nonCalculatedLimit, nonCalculatedLimitOutput, resultLimit, resultLimitSimp, resultOutput, timeLimit

    if flagPortrait:
        init_printing(use_unicode=True, num_columns=50)
    else:
        init_printing(use_unicode=True, num_columns=80)
    timet1=time.time()

    expressionLimit = expression
    variableLimit = variable.strip()
    pointLimit = point.strip()
    limitExpr = u'('+expressionLimit+u','+variableLimit+u','+pointLimit
    if direction != 'Bilateral':
        limitExpr += u',dir=\"'
        if direction == 'Left':
            limitExpr += u'-\"'
        elif direction == 'Right':
            limitExpr += u'+\"'
    limitExpr += u')'

    if direction == 'Bilateral':
        try:
            nonCalculatedLimit = sympify(u'Limit'+limitExpr)
        except:
            nonCalculatedLimit = u'Limit'+limitExpr
    else:
# "Limit" has a bug not showing the "+" and "-" above the point value.
        nonCalculatedLimit = u'Limit'+limitExpr
    if direction == 'Bilateral':
        try:
            if (sympify(u'limit'+limitExpr)) == (sympify(u'limit'+limitExpr[:-1]+u',dir=\"-\")')):
                resultLimit = sympify(u'limit'+limitExpr)
            else:
                resultLimit = u"Bilateral limit does not exist because the limits from the left and right are different."
        except:
            resultLimit = limitErrorMessage
    else:
        try:
            resultLimit = sympify(u'limit'+limitExpr)
        except:
            resultLimit = limitErrorMessage
    if (type(resultLimit) != str) and numerApprox:
        try:
            resultLimit = sympify('N('+str(resultLimit)+','+numDigText+')')
        except:
            resultLimit = limitErrorMessage

    if (resultLimit) and (type(resultLimit) != str) and (not numerApprox):
        if simplifyResult == simplifyType['none']:
            resultLimitSimp = sympify(resultLimit)
        elif simplifyResult == simplifyType['expandterms']:
            resultLimitSimp = sympify(mapexpr(resultLimit,expand))
        elif simplifyResult == simplifyType['simplifyterms']:
            resultLimitSimp = sympify(mapexpr(resultLimit,simplify))
        elif simplifyResult == simplifyType['expandall']:
            resultLimitSimp = sympify(expand(resultLimit))
        elif simplifyResult == simplifyType['simplifyall']:
            resultLimitSimp = sympify(simplify(resultLimit))
    else:
        resultLimitSimp = resultLimit

    timet2=time.time()
    timeLimit = timet2-timet1

    if direction == 'Bilateral':
        nonCalculatedLimitOutput = fixUnicodeText(printing.pretty(nonCalculatedLimit))
    if (type(resultLimitSimp) != str):
        resultOutput = fixUnicodeText(printing.pretty(resultLimitSimp))

    nonCalculatedLimitOutput = str(nonCalculatedLimit)
    resultOutput = str(resultLimitSimp)
    if outputResult == outputType['bidimensional']:
        if (direction == 'Bilateral') and (type(nonCalculatedLimit) != str):
            nonCalculatedLimitOutput = fixUnicodeText(printing.pretty(nonCalculatedLimit))
        if (type(resultLimitSimp) != str):
            resultOutput = fixUnicodeText(printing.pretty(resultLimitSimp))
    elif outputResult == outputType['latex']:
        if (direction == 'Bilateral') and (type(nonCalculatedLimit) != str):
            nonCalculatedLimitOutput = latex(nonCalculatedLimit)
        if (type(resultLimitSimp) != str):
            resultOutput = latex(resultLimitSimp)
    elif outputResult == outputType['c']:
        if (type(resultLimitSimp) != str):
            resultOutput = ccode(resultLimitSimp)
    elif outputResult == outputType['fortran']:
        if (type(resultLimitSimp) != str):
            resultOutput = fcode(resultLimitSimp)
    elif outputResult == outputType['javascript']:
        if (type(resultLimitSimp) != str):
            resultOutput = jscode(resultLimitSimp)
    elif outputResult == outputType['python']:
        if (type(resultLimitSimp) != str):
            resultOutput = python(resultLimitSimp)

    if showTime and (timeLimit > 0.0):
        pyotherside.send("timerPush", ("%fs" % timeLimit))
        result = u""
    else:
        result = u""
    if showLimit and nonCalculatedLimitOutput:
        result += nonCalculatedLimitOutput + '\n\n'
    if (type(resultLimitSimp) != str):
        result += resultOutput
    else:
        #pyotherside.send("errorPush", resultOutput)
        result += u''+resultOutput #.replace(' ','&nbsp;')).replace("\n","<br>"))
    return result
