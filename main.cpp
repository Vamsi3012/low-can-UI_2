#include <QGuiApplication>
#include <QQmlApplicationEngine>
#include <QCommandLineParser>
#include <QUrlQuery>
#include <QQmlContext>
#include <QFont>

int main(int argc, char *argv[])
{
    QCoreApplication::setAttribute(Qt::AA_EnableHighDpiScaling);
    QGuiApplication app(argc, argv);
    app.setApplicationName(QStringLiteral("Low_CAN"));
    QFont font;
    font.setBold(true);
    font.setPointSize(30);
    app.setFont(font);

    QCommandLineParser parser;
    parser.addPositionalArgument("port", app.translate("main", "port for binding"));
    parser.addPositionalArgument("secret", app.translate("main", "secret for binding"));
    parser.addHelpOption();
    parser.addVersionOption();
    parser.process(app);
    QStringList positionalArguments = parser.positionalArguments();

    QQmlApplicationEngine engine;

    if (positionalArguments.length() == 2) {
        int port = positionalArguments.takeFirst().toInt();
        QString secret = positionalArguments.takeFirst();
        QUrl bindingAddressCAN, bindingAddressHono;
        bindingAddressCAN.setScheme(QStringLiteral("ws"));
        bindingAddressCAN.setHost(QStringLiteral("localhost"));
        bindingAddressCAN.setPort(port);
        bindingAddressCAN.setPath(QStringLiteral("/api"));
        QUrlQuery query, queryHono;
        query.addQueryItem(QStringLiteral("token"), secret);
        bindingAddressCAN.setQuery(query);
        bindingAddressHono.setScheme(QStringLiteral("ws"));
        bindingAddressHono.setHost(QStringLiteral("localhost"));
        bindingAddressHono.setPort(port + 1);
        bindingAddressHono.setPath(QStringLiteral("/api"));
        queryHono.addQueryItem(QStringLiteral("token"), secret + 1);
        bindingAddressHono.setQuery(queryHono);
        QQmlContext *context = engine.rootContext();
        context->setContextProperty(QStringLiteral("bindingAddressCAN"), bindingAddressCAN);
    }
    engine.load(QUrl(QLatin1String("qrc:/main.qml")));
    if (engine.rootObjects().isEmpty())
        return -1;

    return app.exec();
}
