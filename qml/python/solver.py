import pyotherside
import sys
import time
import os
from platform import python_version
import platform
import threading
from enum import Enum, IntEnum, unique

(major, minor, micro, release, serial) = sys.version_info
sys.path.append("/usr/share/Solver/lib/python" + str(major) + "." + str(minor) + "/site-packages/");

timet1=time.time()

from sympy import *
from sympy import __version__
from mpmath import *
from sympy.interactive.printing import init_printing
from sympy.printing.mathml import print_mathml

timet2=time.time()
loadingtimeSymPy = timet2-timet1

versionPython = python_version()
versionSymPy = __version__

simplifyType = {'none':0, 'expandterms':1, 'simplifyterms':2, 'expandall':3, \
                'simplifyall':4}

outputType = {'simple':0, 'bidimensional':1, 'latex':2, 'c':3, \
              'fortran':4, 'javascript':5, 'python':6}


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

def fixMPMathText(str):
    str = str.replace("oo","inf")
    str = str.replace("E","e")
    str = str.replace("I","j")
    str = str.replace("j","i")
    str = str.replace("GoldenRatio","phi")
    return str

# Derivative
nonCalculatedDerivative = ""
nonCalculatedDerivativeOutput = ""
resultDerivative = ""
resultDerivativeSimp = ""
resultOutput = ""
timeDerivative = 0.0
derivativeErrorMessage = 'Error: derivative not calculated'

numerApprox = False

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



# limit

nonCalculatedLimit = ""
nonCalculatedLimitOutput = ""
resultLimit = ""
resultLimitSimp = ""
resultOutput = ""
timeLimit = 0.0
limitErrorMessage = 'Error: limit not calculated'

numerApprox = False

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


# Integral
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

# Solver
nonCalculatedEquator = ""
nonCalculatedEquatorOutput = ""
resultEquator = ""
resultEquatorSimp = ""
resultOutput = ""
timeEquator = 0.0
EquatorErrorMessage = 'Error: Solution not calculated'

numerApprox = False

def calculate_Solver(expressionLeft, expressionRight, var1,var2,var3,\
                         numColumns,showEquator,showTime,numerApprox,numDigText,\
                         simplifyResult,outputResult):
    global nonCalculatedEquator, nonCalculatedEquatorOutput, resultEquator, \
           resultEquatorSimp, resultOutput, timeEquator

    init_printing(use_unicode=True, num_columns=numColumns)
    timet1=time.time()

    # First build the equation
    solveFor = 'Eq(' + expressionLeft +',' + expressionRight +')'

    # now assemble the vars to solve for
    variable1Equator = var1.strip()
    variable2Equator = var2.strip()
    variable3Equator = var3.strip()
    # assemble command
    EquatorExpr = '(' + solveFor
    if (variable1Equator):
        EquatorExpr += ','+variable1Equator
    if (variable2Equator):
        EquatorExpr += ','+variable2Equator
    if (variable3Equator):
        EquatorExpr += ','+variable3Equator
    EquatorExpr += u')'

    # execute 'solve'
    try:
        nonCalculatedEquator = sympify('solve'+EquatorExpr)
    except:
        nonCalculatedEquator = 'solve'+EquatorExpr
    '''
    try:
        if numerApprox:
            resultEquator = sympify('N(diff'+EquatorExpr+','+numDigText+')')
        else:
            resultEquator = sympify('diff'+EquatorExpr)
    except:
        resultEquator = EquatorErrorMessage
    '''

    if (resultEquator) and (type(resultEquator) != str):
        if (simplifyResult == simplifyType['none']) or (numerApprox):
            resultEquatorSimp = sympify(resultEquator)
        elif simplifyResult == simplifyType['expandterms']:
            resultEquatorSimp = sympify(mapexpr(resultEquator,expand))
        elif simplifyResult == simplifyType['simplifyterms']:
            resultEquatorSimp = sympify(mapexpr(resultEquator,simplify))
        elif simplifyResult == simplifyType['expandall']:
            resultEquatorSimp = sympify(expand(resultEquator))
        elif simplifyResult == simplifyType['simplifyall']:
            resultEquatorSimp = sympify(simplify(resultEquator))
    else:
        resultEquatorSimp = resultEquator

    timet2=time.time()
    timeEquator = timet2-timet1

    nonCalculatedEquatorOutput = str(nonCalculatedEquator)
    resultOutput = str(resultEquatorSimp)
    if outputResult == outputType['bidimensional']:
        if (type(nonCalculatedEquator) != str):
            nonCalculatedEquatorOutput = fixUnicodeText(printing.pretty(nonCalculatedEquator))
        if (type(resultEquatorSimp) != str):
            resultOutput = fixUnicodeText(printing.pretty(resultEquatorSimp))
    elif outputResult == outputType['latex']:
        if (type(nonCalculatedEquator) != str):
            nonCalculatedEquatorOutput = latex(nonCalculatedEquator)
        if (type(resultEquatorSimp) != str):
            resultOutput = latex(resultEquatorSimp)
#    elif outputResult == outputType['mathml']:
#        if (type(nonCalculatedEquator) != str):
#            nonCalculatedEquatorOutput = str(mathml(nonCalculatedEquator))
#        if (type(resultEquatorSimp) != str):
#            resultOutput = str(print_mathml(resultEquatorSimp))
    elif outputResult == outputType['c']:
        if (type(resultEquatorSimp) != str):
            resultOutput = ccode(resultEquatorSimp)
    elif outputResult == outputType['fortran']:
        if (type(resultEquatorSimp) != str):
            resultOutput = fcode(resultEquatorSimp)
    elif outputResult == outputType['javascript']:
        if (type(resultEquatorSimp) != str):
            resultOutput = jscode(resultEquatorSimp)
    elif outputResult == outputType['python']:
        if (type(resultEquatorSimp) != str):
            resultOutput = python(resultEquatorSimp)


    if showTime and (timeEquator > 0.0):
        pyotherside.send("timerPush", timeEquator)
        result = u'\n\n'
        #result = '<FONT COLOR="LightGreen">'+("Calculated in %fs :" % timeEquator)+'</FONT><br><br>'
    else:
        result = u"\n\n"
    if showEquator and nonCalculatedEquatorOutput:
        result += fixUnicodeText(printing.pretty(sympify(solveFor))) + '\n\n'
        result+= nonCalculatedEquatorOutput + '\n\n'
    if (type(resultEquatorSimp) != str):
        result+= resultOutput + '\n\n'
        #result += (resultOutput.replace(' ','&nbsp;')).replace("\n","<br>")
    else:
        result+= resultOutput + '\n\n'
    return result

