
nonCalculatedDerivative = ""
nonCalculatedDerivativeOutput = ""
resultDerivative = ""
resultDerivativeSimp = ""
resultOutput = ""
timeDerivative = 0.0
derivativeErrorMessage = 'Error: derivative not calculated'

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

def calculate_Derivative(expression,var1,numvar1,var2,numvar2,var3,numvar3,\
                         numColumns,showDerivative,showTime,numerApprox,numDigText,\
                         simplifyResult,outputResult):
    global nonCalculatedDerivative, nonCalculatedDerivativeOutput, resultDerivative, \
           resultDerivativeSimp, resultOutput, timeDerivative

    init_printing(use_unicode=True, num_columns=numColumns)
    timet1=time.time()

    expressionDerivative = expression
    variable1Derivative = var1.strip()
    numVar1Derivative = numvar1.strip()
    if not numVar1Derivative:
        numVar1Derivative = '0'
    variable2Derivative = var2.strip()
    numVar2Derivative = numvar2.strip()
    if not numVar2Derivative:
        numVar2Derivative = '0'
    variable3Derivative = var3.strip()
    numVar3Derivative = numvar3.strip()
    if not numVar3Derivative:
        numVar3Derivative = '0'

    derivativeExpr = '('+expressionDerivative
    if variable1Derivative and (eval(numVar1Derivative) > 0):
        derivativeExpr += ','+variable1Derivative+','+numVar1Derivative
    if variable2Derivative and (eval(numVar2Derivative) > 0):
        derivativeExpr += ','+variable2Derivative+','+numVar2Derivative
    if variable3Derivative and (eval(numVar3Derivative) > 0):
        derivativeExpr += ','+variable3Derivative+','+numVar3Derivative
    derivativeExpr += u')'
    try:
        nonCalculatedDerivative = sympify('Derivative'+derivativeExpr)
    except:
        nonCalculatedDerivative = 'Derivative'+derivativeExpr
    try:
        if numerApprox:
            resultDerivative = sympify('N(diff'+derivativeExpr+','+numDigText+')')
        else:
            resultDerivative = sympify('diff'+derivativeExpr)
    except:
        resultDerivative = derivativeErrorMessage

    if (resultDerivative) and (type(resultDerivative) != str):
        if (simplifyResult == simplifyType['none']) or (numerApprox):
            resultDerivativeSimp = sympify(resultDerivative)
        elif simplifyResult == simplifyType['expandterms']:
            resultDerivativeSimp = sympify(mapexpr(resultDerivative,expand))
        elif simplifyResult == simplifyType['simplifyterms']:
            resultDerivativeSimp = sympify(mapexpr(resultDerivative,simplify))
        elif simplifyResult == simplifyType['expandall']:
            resultDerivativeSimp = sympify(expand(resultDerivative))
        elif simplifyResult == simplifyType['simplifyall']:
            resultDerivativeSimp = sympify(simplify(resultDerivative))
    else:
        resultDerivativeSimp = resultDerivative

    timet2=time.time()
    timeDerivative = timet2-timet1

    nonCalculatedDerivativeOutput = str(nonCalculatedDerivative)
    resultOutput = str(resultDerivativeSimp)
    if outputResult == outputType['bidimensional']:
        if (type(nonCalculatedDerivative) != str):
            nonCalculatedDerivativeOutput = fixUnicodeText(printing.pretty(nonCalculatedDerivative))
        if (type(resultDerivativeSimp) != str):
            resultOutput = fixUnicodeText(printing.pretty(resultDerivativeSimp))
    elif outputResult == outputType['latex']:
        if (type(nonCalculatedDerivative) != str):
            nonCalculatedDerivativeOutput = latex(nonCalculatedDerivative)
        if (type(resultDerivativeSimp) != str):
            resultOutput = latex(resultDerivativeSimp)
#    elif outputResult == outputType['mathml']:
#        if (type(nonCalculatedDerivative) != str):
#            nonCalculatedDerivativeOutput = str(mathml(nonCalculatedDerivative))
#        if (type(resultDerivativeSimp) != str):
#            resultOutput = str(print_mathml(resultDerivativeSimp))
    elif outputResult == outputType['c']:
        if (type(resultDerivativeSimp) != str):
            resultOutput = ccode(resultDerivativeSimp)
    elif outputResult == outputType['fortran']:
        if (type(resultDerivativeSimp) != str):
            resultOutput = fcode(resultDerivativeSimp)
    elif outputResult == outputType['javascript']:
        if (type(resultDerivativeSimp) != str):
            resultOutput = jscode(resultDerivativeSimp)
    elif outputResult == outputType['python']:
        if (type(resultDerivativeSimp) != str):
            resultOutput = python(resultDerivativeSimp)

    if showTime and (timeDerivative > 0.0):
        pyotherside.send("timerPush", timeDerivative)
        result = u'\n\n'
        #result = '<FONT COLOR="LightGreen">'+("Calculated in %fs :" % timeDerivative)+'</FONT><br><br>'
    else:
        result = u"\n\n"
    if showDerivative and nonCalculatedDerivativeOutput:
        result+= nonCalculatedDerivativeOutput + '\n\n'
        #result += u'<FONT COLOR="LightBlue">'+(nonCalculatedDerivativeOutput.replace(' ','&nbsp;')).replace("\n","<br>")+'<br>=</FONT><br>'
    if (type(resultDerivativeSimp) != str):
        result+= resultOutput + '\n\n'
        #result += (resultOutput.replace(' ','&nbsp;')).replace("\n","<br>")
    else:
        result+= resultOutput + '\n\n'
        #result += u'<FONT COLOR="Red">'+((resultOutput.replace(' ','&nbsp;')).replace("\n","<br>"))+'</FONT>'
    return result

