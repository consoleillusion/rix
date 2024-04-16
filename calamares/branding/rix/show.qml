import QtQuick 2.0;
import calamares.slideshow 1.0;

Presentation {
    id: presentation

    function nextSlide() {
        presentation.goToNextSlide();
    }

    Timer {
        id: advanceTimer
        interval: 12000
        running: presentation.activatedInCalamares
        repeat: true
        onTriggered: nextSlide()
    }

    function onActivate() {
        presentation.currentSlide = 0;
        advanceTimer.restart();
    }

    function onLeave() {
        advanceTimer.stop();
    }

    Slide {
        Column {
            anchors.centerIn: parent
            spacing: 28

            Image {
                source: "rix-mark.svg"
                width: 140
                height: 140
                fillMode: Image.PreserveAspectFit
                anchors.horizontalCenter: parent.horizontalCenter
            }

            Text {
                anchors.horizontalCenter: parent.horizontalCenter
                text: qsTr("Installing Rix")
                color: "#F4F1FF"
                font.pixelSize: 34
                font.bold: true
            }

            Text {
                anchors.horizontalCenter: parent.horizontalCenter
                text: qsTr("A reproducible, declarative system built on NixOS.")
                color: "#B69CFF"
                font.pixelSize: 16
            }
        }
    }

    Slide {
        Column {
            anchors.centerIn: parent
            spacing: 20

            Text {
                anchors.horizontalCenter: parent.horizontalCenter
                text: qsTr("Nothing is overwritten")
                color: "#B69CFF"
                font.pixelSize: 30
                font.bold: true
            }

            Text {
                width: presentation.width * 0.8
                wrapMode: Text.WordWrap
                horizontalAlignment: Text.AlignHCenter
                anchors.horizontalCenter: parent.horizontalCenter
                color: "#F4F1FF"
                font.pixelSize: 16
                text: qsTr("Every package is built in isolation and stored under a unique path. Upgrades never break the running system, and you can roll back to any previous generation from the boot menu.")
            }
        }
    }

    Slide {
        Column {
            anchors.centerIn: parent
            spacing: 20

            Text {
                anchors.horizontalCenter: parent.horizontalCenter
                text: qsTr("Yours to shape")
                color: "#B69CFF"
                font.pixelSize: 30
                font.bold: true
            }

            Text {
                width: presentation.width * 0.8
                wrapMode: Text.WordWrap
                horizontalAlignment: Text.AlignHCenter
                anchors.horizontalCenter: parent.horizontalCenter
                color: "#F4F1FF"
                font.pixelSize: 16
                text: qsTr("The whole system is described by configuration files. Edit them, rebuild, and Rix applies exactly what you asked for — on this machine or a thousand others.")
            }
        }
    }
}
