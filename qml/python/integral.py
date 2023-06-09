
integralType = {'indefinite':0, 'definite':1, 'numerical':2}
numerIntegralType = {'approx':0, 'infinities':1, 'smooth':2}

nonCalculatedIntegral = ""
nonCalculatedIntegralOutput = ""
resultIntegral = ""
resultIntegralSimp = ""
resultOutput = ""
timeIntegral = 0.0
integralErrorMessage = 'Error: integral not calculated'
integralNumerErrorMessage = 'Error: numerical integral not calculated'

def mapexpr(expr,func):
    if isinstance(expr,Add):
        return Add(*map(func,expr.args))
    else:
        return func(expr)

def fixMPMathText(str):
    str = str.replace("oo","inf")
    str = str.replace("E","e")
    str = str.replace("I","j")
    str = str.replace("GoldenRatio","phi")
    return str

def fixMPMathOutput(str):
    str = str.replace("j","i")
    return str

def fixUnicodeText(text):
    text = text.replace(u"⎽","_")
    text = text.replace(u"ℯ","e")
    text = text.replace(u"ⅈ","i")
    return text

def calculate_Integral(expression,var1,var2,var3,varSup1,varSup2,varSup3,varInf1,varInf2,varInf3,\
                       typeIntegral,numDimensions,numColumns,\
                       showIntegral,showTime,numDigText,numerTypeIntegral,simplifyResult,outputResult):
    global nonCalculatedIntegral, nonCalculatedIntegralOutput, resultIntegral, resultIntegralSimp, resultOutput, timeIntegral

    init_printing(use_unicode=True, num_columns=numColumns)
    timet1=time.time()

    integrand = expression
    diffvar1 = var1.strip()
    diffvar2 = var2.strip()
    diffvar3 = var3.strip()
    limSup1 = varSup1.strip()
    limSup2 = varSup2.strip()
    limSup3 = varSup3.strip()
    limInf1 = varInf1.strip()
    limInf2 = varInf2.strip()
    limInf3 = varInf3.strip()

    integrateExpr = '('+integrand+','
    if typeIntegral == integralType['indefinite']:
        integrateExpr += diffvar1
        if numDimensions > 1:
            integrateExpr += ','+diffvar2
        if numDimensions > 2:
            integrateExpr += ','+diffvar3
        integrateExpr += ')'
        try:
            nonCalculatedIntegral = sympify('Integral'+integrateExpr)
        except:
            nonCalculatedIntegral = 'Integral'+integrateExpr
        try:
            resultIntegral = sympify('integrate'+integrateExpr)
        except:
            resultIntegral = integralErrorMessage
    else:
        integrateExpr += '('+diffvar1+','+limInf1+','+limSup1+')'
        if numDimensions > 1:
            integrateExpr += ',('+diffvar2+','+limInf2+','+limSup2+')'
        if numDimensions > 2:
            integrateExpr += ',('+diffvar3+','+limInf3+','+limSup3+')'
        integrateExpr += ')'
        try:
            nonCalculatedIntegral = sympify('Integral'+integrateExpr)
        except:
            nonCalculatedIntegral = 'Integral'+integrateExpr
        if typeIntegral == integralType['definite']:
            try:
                resultIntegral = sympify('integrate'+integrateExpr)
            except:
                resultIntegral = integralErrorMessage
        else:
            if numerTypeIntegral == numerIntegralType['approx']:
                try:
                    resultIntegral = sympify('N(integrate'+integrateExpr+','+numDigText+')')
                except:
                    resultIntegral = integralErrorMessage
            else:
                mp.dps=int(numDigText)
                integrateExpr = "(lambda "
                if numDimensions > 2:
                    integrateExpr += diffvar3+","
                if numDimensions > 1:
                    integrateExpr += diffvar2+","
                integrand = fixMPMathText(integrand)
                integrateExpr += diffvar1+": "+integrand
                if numDimensions > 2:
                    limInf3 = fixMPMathText(limInf3)
                    limSup3 = fixMPMathText(limSup3)
                    integrateExpr += ',['+limInf3+','+limSup3+']'
                if numDimensions > 1:
                    limInf2 = fixMPMathText(limInf2)
                    limSup2 = fixMPMathText(limSup2)
                    integrateExpr += ',['+limInf2+','+limSup2+']'
                limInf1 = fixMPMathText(limInf1)
                limSup1 = fixMPMathText(limSup1)
                integrateExpr += ",["+limInf1+","+limSup1+"])"
                try:
                    if numerTypeIntegral == numerIntegralType['infinities']:
                        resultIntegral = eval("quadts"+integrateExpr)
                    else:
                        resultIntegral = eval("quadgl"+integrateExpr)
                    resultIntegral = sympify('N('+fixMPMathOutput(str(resultIntegral))+','+numDigText+')')
                except:
                    resultIntegral = integralNumerErrorMessage

    if (resultIntegral) and (type(resultIntegral) != str) and (typeIntegral != integralType['numerical']):
        if simplifyResult == simplifyType['none']:
            resultIntegralSimp = sympify(resultIntegral)
        elif simplifyResult == simplifyType['expandterms']:
            resultIntegralSimp = sympify(mapexpr(resultIntegral,expand))
        elif simplifyResult == simplifyType['simplifyterms']:
            resultIntegralSimp = sympify(mapexpr(resultIntegral,simplify))
        elif simplifyResult == simplifyType['expandall']:
            resultIntegralSimp = sympify(expand(resultIntegral))
        elif simplifyResult == simplifyType['simplifyall']:
            resultIntegralSimp = sympify(simplify(resultIntegral))
    else:
        resultIntegralSimp = resultIntegral

    timet2=time.time()
    timeIntegral = timet2-timet1

    nonCalculatedIntegralOutput = str(nonCalculatedIntegral)
    resultOutput = str(resultIntegralSimp)
    if outputResult == outputType['bidimensional']:
        if (type(nonCalculatedIntegral) != str):
            nonCalculatedIntegralOutput = fixUnicodeText(printing.pretty(nonCalculatedIntegral))
        if (type(resultIntegralSimp) != str):
            resultOutput = fixUnicodeText(printing.pretty(resultIntegralSimp))
    elif outputResult == outputType['latex']:
        if (type(nonCalculatedIntegral) != str):
            nonCalculatedIntegralOutput = latex(nonCalculatedIntegral)
        if (type(resultIntegralSimp) != str):
            resultOutput = latex(resultIntegralSimp)
    elif outputResult == outputType['c']:
        if (type(resultIntegralSimp) != str):
            resultOutput = ccode(resultIntegralSimp)
    elif outputResult == outputType['fortran']:
        if (type(resultIntegralSimp) != str):
            resultOutput = fcode(resultIntegralSimp)
    elif outputResult == outputType['javascript']:
        if (type(resultIntegralSimp) != str):
            resultOutput = jscode(resultIntegralSimp)
    elif outputResult == outputType['python']:
        if (type(resultIntegralSimp) != str):
            resultOutput = python(resultIntegralSimp)

    if showTime and (timeIntegral > 0.0):
        pyotherside.send("timerPush", timeIntegral)
        result = u'\n\n'
        #result = '<FONT COLOR="LightGreen">'+("Calculated after %f s :" % timeIntegral)+'</FONT><br>'
    else:
        result = u'\n\n'
    if showIntegral and nonCalculatedIntegralOutput:
        result+= nonCalculatedIntegralOutput + '\n\n'
        #result += u'<FONT COLOR="LightBlue">'+(nonCalculatedIntegralOutput.replace(' ','&nbsp;')).replace("\n","<br>")+'<br>=</FONT><br>'
    if (type(resultIntegralSimp) != str):
        result += resultOutput + '\n'
        #result += (resultOutput.replace(' ','&nbsp;')).replace("\n","<br>")
    else:
        result += resultOutput
        #result += u'<FONT COLOR="Red">'+((resultOutput.replace(' ','&nbsp;')).replace("\n","<br>"))+'</FONT>'
    return result

