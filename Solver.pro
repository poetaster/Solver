# NOTICE:
#
# Application name defined in TARGET has a corresponding QML filename.
# If name defined in TARGET is changed, the following needs to be done
# to match new name:
#   - corresponding QML filename must be changed
#   - desktop icon filename must be changed
#   - desktop filename must be changed
#   - icon definition filename in desktop file must be changed
#   - translation filenames have to be changed

# The name of your application
TARGET = harbour-solver

CONFIG += sailfishapp_qml

OTHER_FILES += qml/haroub-solver.qml \
    qml/cover/CoverPage.qml \
    qml/components/* \
    qml/pages/Derivative.qml \
    qml/pages/Integral.qml \
    qml/pages/Limit.qml \
    qml/pages/Solver.qml \
    qml/pages/SettingsPage.qml \
    qml/pages/AboutPage.qml \
    qml/pages/HelpPage.qml \
    qml/pages/Carousel.qml \
    qml/pages/Solver.qml \
    qml/pages/DejaVuSansMono.ttf \
    qml/js/strorage.js \
    rpm/harbour-solver.spec \
    rpm/harbour-solver.changes \
    harbour-solver.desktop \
    translations/*.ts \
    rpm/harbour-solver.changes \

#CONFIG += sailfishapp_i18n
#TRANSLATIONS += translations/harbour-solver-de.ts

python.path = /usr/share/$${TARGET}/qml
python.files = python

#libs.path = /usr/share/$${TARGET}
#libs.files = lib

INSTALLS += python
#INSTALLS += libs

SAILFISHAPP_ICONS = 86x86 108x108 128x128 172x172
