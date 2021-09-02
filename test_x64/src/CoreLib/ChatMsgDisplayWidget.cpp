#include "ChatMsgDisplayWidget.h"
#include "ToolFunc.h"

#include <QPainter>
#include <QMouseEvent>
#include <QDesktopServices>
#include <QFileInfo>
#include <QFileIconProvider>
#include <QDir>
#include <QMessageBox>
#include <QApplication>
#include <QSettings>
#include <QDesktopWidget>
#include <QFile>
#include <QFileDialog>
#include <QTime>
#include <QList>
#include <QHostAddress>
#include <QNetworkInterface>
#include <QBitmap>
#include <QMenu>
#include <QClipboard>
#include <QHBoxLayout>
#include <QScrollBar>


////////////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////////////

class helper
{
public:
	static void AutoRunWithSystem(bool IsAutoRun, QString AppName)
	{
		QString AppPath = QApplication::applicationFilePath();
		AppPath = AppPath.replace("/", "\\");

		QSettings *reg = new QSettings(
			"HKEY_LOCAL_MACHINE\\SOFTWARE\\Microsoft\\Windows\\CurrentVersion\\Run",
			QSettings::NativeFormat);

		if (IsAutoRun) 
		{ 
			reg->setValue(AppName, AppPath); 
		}
		else 
		{ 
			reg->setValue(AppName, ""); 
		}
	}

	static void SetUTF8Code()
	{
#if (QT_VERSION < QT_VERSION_CHECK(5,0,0))
		QTextCodec *codec = QTextCodec::codecForName("UTF-8");
		QTextCodec::setCodecForLocale(codec);
		QTextCodec::setCodecForCStrings(codec);
		QTextCodec::setCodecForTr(codec);
#endif
	}

	static void FormOnlyCloseInCenter(QWidget *frm)
	{
		QDesktopWidget desktop;
		int screenX = desktop.availableGeometry().width();
		int screenY = desktop.availableGeometry().height() - 40;
		int frmX = frm->width();
		int frmY = frm->height();
		QPoint movePoint(screenX / 2 - frmX / 2, screenY / 2 - frmY / 2);
		frm->move(movePoint);

		frm->setFixedSize(frmX, frmY);

		frm->setWindowFlags(Qt::WindowCloseButtonHint);
	}

	static void FormInCenter(QWidget *frm)
	{
		int screenX = qApp->desktop()->availableGeometry().width();
		int screenY = qApp->desktop()->availableGeometry().height() - 60;
		int wndX = frm->width();
		int wndY = frm->height();
		QPoint movePoint((screenX - wndX) / 2, (screenY - wndY) / 2);
		frm->move(movePoint);
	}

	static void FormNoMaxButton(QWidget *frm)
	{
		frm->setWindowFlags(Qt::WindowMinimizeButtonHint);
	}

	static void FormOnlyCloseButton(QWidget *frm)
	{
		frm->setWindowFlags(Qt::WindowCloseButtonHint);
	}

	static void FormNotResize(QWidget *frm)
	{
		frm->setFixedSize(frm->width(), frm->height());
	}

	static void setStyle(const QString &style) 
	{
		QFile file(":/qss/resource/qss/" + style + ".css");
		file.open(QIODevice::ReadOnly);
		qApp->setStyleSheet(file.readAll());
		file.close();
	}

	static void Sleep(int sec)
	{
		QTime dieTime = QTime::currentTime().addMSecs(sec);
		while (QTime::currentTime() < dieTime)
			QCoreApplication::processEvents(QEventLoop::AllEvents, 100);
	}

	static bool IsIP(QString IP)
	{
		QRegExp RegExp("((2[0-4]\\d|25[0-5]|[01]?\\d\\d?)\\.){3}(2[0-4]\\d|25[0-5]|[01]?\\d\\d?)");
		return RegExp.exactMatch(IP);
	}

	static QString GetIP()
	{
		QList<QHostAddress> list = QNetworkInterface::allAddresses();

		foreach(QHostAddress address, list)
		{
			if (address.protocol() == QAbstractSocket::IPv4Protocol)
				return address.toString();
		}
		return "";
	}
	
	static QString GetFileSize(const QString &name) 
	{
		//QFileInfo fileInfo(MyApp::m_strRecvPath + name);
		return 0;//CalcSize(fileInfo.size());
	}

	static QString GetFileName(QString filter)
	{
		return QFileDialog::getOpenFileName(NULL, "选择文件", QCoreApplication::applicationDirPath(), filter);
	}

	static QStringList GetFileNames(QString filter)
	{
		return QFileDialog::getOpenFileNames(NULL, "选择文件", QCoreApplication::applicationDirPath(), filter);
	}

	static QString GetFolderName()
	{
		return QFileDialog::getExistingDirectory();;
	}

	static QString GetFileNameWithExtension(QString strFilePath)
	{
		QFileInfo fileInfo(strFilePath);
		return fileInfo.fileName();
	}

	static QStringList GetFolderFileNames(QStringList filter)
	{
		QStringList fileList;
		QString strFolder = QFileDialog::getExistingDirectory();
		if (!strFolder.length() == 0)
		{
			QDir myFolder(strFolder);

			if (myFolder.exists())
			{
				fileList = myFolder.entryList(filter);
			}
		}
		return fileList;
	}

	static bool FolderIsExist(QString strFolder)
	{
		QDir tempFolder(strFolder);
		return tempFolder.exists();
	}

	static bool FileIsExist(QString strFile)
	{
		QFile tempFile(strFile);
		return tempFile.exists();
	}

	static void CleanDirPath(QString strPath) 
	{
		QDir dir(strPath);

		foreach(QFileInfo mfi, dir.entryInfoList())
		{
			if (mfi.isFile())
			{
				if (mfi.fileName().endsWith("wav")) 
				{
					bool bOk = QFile::remove(mfi.filePath());
					qDebug() << "Remove Old record files:" << bOk << mfi.filePath();
				}
			}
			else
			{
				if (mfi.fileName() == "." || mfi.fileName() == "..") 
					continue;
				CleanDirPath(mfi.absoluteFilePath());
			}
		}
	}

	static bool CopyFile(QString sourceFile, QString targetFile)
	{
		if (FileIsExist(targetFile))
		{
			int ret = QMessageBox::information(NULL, "提示", "文件已经存在，是否替换？", QMessageBox::Yes | QMessageBox::No);
			if (ret != QMessageBox::Yes)
			{
				return false;
			}
		}

		return QFile::copy(sourceFile, targetFile);
	}

	static void PlaySound(const QString &name)
	{
		//        QString strSound = MyApp::m_strSoundPath + name + ".wav";
		//        if (!QFile::exists(strSound)) return;
		//        QSound::play(strSound);
	}

	static void stringToHtmlFilter(QString &str)
	{
		//注意这几行代码的顺序不能乱，否则会造成多次替换
		str.replace("&", "&amp;");
		str.replace(">", "&gt;");
		str.replace("<", "&lt;");
		str.replace("\"", "&quot;");
		str.replace("\'", "&#39;");
		str.replace(" ", "&nbsp;");
		str.replace("\n", "<br>");
		str.replace("\r", "<br>");
	}

	static void stringToHtml(QString &str, QColor crl)
	{
		QByteArray array;
		array.append(crl.red());
		array.append(crl.green());
		array.append(crl.blue());
		QString strC(array.toHex());
		str = QString("<span style=\" color:#%1;\">%2</span>").arg(strC).arg(str);
	}

	static void imgPathToHtml(QString &path)
	{
		path = QString("<img src=\"%1\"/>").arg(path);
	}

	static void stringToText(QString &str)
	{
		str = QString("<span><p>  %1</span></p>").arg(str);
	}

	static QPixmap PixmapToRound(const QPixmap &src, int radius)
	{
		if (src.isNull()) 
		{
			return QPixmap();
		}

		QSize size(2 * radius, 2 * radius);
		QBitmap mask(size);
		QPainter painter(&mask);
		painter.setRenderHint(QPainter::Antialiasing);
		painter.setRenderHint(QPainter::SmoothPixmapTransform);
		painter.fillRect(0, 0, size.width(), size.height(), Qt::white);
		painter.setBrush(QColor(0, 0, 0));
		painter.drawRoundedRect(0, 0, size.width(), size.height(), 99, 99);

		QPixmap image = src.scaled(size);
		image.setMask(mask);
		return image;
	}

	static QPixmap ChangeGrayPixmap(const QImage &image)
	{
		QImage newImage = image;
		if (newImage.isNull())
		{
			return QPixmap();
		}

		QColor oldColor;

		for (int x = 0; x < newImage.width(); x++) 
		{
			for (int y = 0; y < newImage.height(); y++) 
			{
				oldColor = QColor(newImage.pixel(x, y));
				int average = (oldColor.red() + oldColor.green() + oldColor.blue()) / 3;
				newImage.setPixel(x, y, qRgb(average, average, average));
			}
		}

		return QPixmap::fromImage(newImage);
	}

	static QString CalcSize(qint64 bytes)
	{
		QString strUnit;
		double dSize = bytes * 1.0;

		if (dSize <= 0)
		{
			dSize = 0.0;
		}
		else if (dSize < 1024)
		{
			strUnit = "Bytes";
		}
		else if (dSize < 1024 * 1024)
		{
			dSize /= 1024;
			strUnit = "KB";
		}
		else if (dSize < 1024 * 1024 * 1024)
		{
			dSize /= (1024 * 1024);
			strUnit = "MB";
		}
		else
		{
			dSize /= (1024 * 1024 * 1024);
			strUnit = "GB";
		}

		return QString("%1 %2").arg(QString::number(dSize, 'f', 2)).arg(strUnit);
	}

	static QString CalcSpeed(double speed)
	{
		QString strUnit;

		if (speed <= 0)
		{
			speed = 0;
			strUnit = "Bytes/S";
		}
		else if (speed < 1024)
		{
			strUnit = "Bytes/S";
		}
		else if (speed < 1024 * 1024)
		{
			speed /= 1024;
			strUnit = "KB/S";
		}
		else if (speed < 1024 * 1024 * 1024)
		{
			speed /= (1024 * 1024);
			strUnit = "MB/S";
		}
		else
		{
			speed /= (1024 * 1024 * 1024);
			strUnit = "GB/S";
		}

		QString strSpeed = QString::number(speed, 'f', 2);
		return QString("%1 %2").arg(strSpeed).arg(strUnit);
	}
};

////////////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////////////
InfoItem::InfoItem() :
	m_strName(""),
	m_strDatetime(""),
	m_strPixmap(""),
	m_strText(""),
	m_strSize(""),
	m_orientation(Left),
	m_msgType(Text),
	m_itemHeight(ITEM_HEIGHT)
{

}

InfoItem::InfoItem(const QString &strName, const QString &datetime, const QString &pixmap, const QString &text, 
							const QString &strSize, const quint8 &orientation, const quint8 &msgType) :
	m_strName(strName),
	m_strDatetime(datetime),
	m_strPixmap(pixmap),
	m_strText(text),
	m_strSize(strSize),
	m_orientation(orientation),
	m_msgType(msgType),
	m_itemHeight(ITEM_HEIGHT)
{

}

InfoItem::~InfoItem() 
{

}

void InfoItem::SetName(const QString &text)
{
	m_strName = text;
}

QString InfoItem::GetName() const
{
	return m_strName;
}

void InfoItem::SetDatetime(const QString &text)
{
	m_strDatetime = text;
}

QString InfoItem::GetDatetime() const
{
	return m_strDatetime;
}

void InfoItem::SetHeadPixmap(const QString &pixmap)
{
	m_strPixmap = pixmap;
}

QString InfoItem::GetStrPixmap() const 
{
	return m_strPixmap;
}

void InfoItem::SetText(const QString &text)
{
	m_strText = text;
}

QString InfoItem::GetText() const
{
	return m_strText;
}

void InfoItem::SetFileSizeString(const QString &strSize)
{
	m_strSize = strSize;
}

QString InfoItem::GetFileSizeString() const
{
	return m_strSize;
}

quint8 InfoItem::GetOrientation() const
{
	return m_orientation;
}

void InfoItem::SetOrientation(quint8 orientation)
{
	m_orientation = orientation;
}

quint8 InfoItem::GetMsgType() const
{
	return m_msgType;
}

void InfoItem::SetMsgType(const quint8 &msgType)
{
	m_msgType = msgType;
}

qreal InfoItem::GetItemHeight() const
{
	return m_itemHeight;
}

void InfoItem::SetItemHeight(qreal itemHeight)
{
	m_itemHeight = itemHeight;
}

QRectF InfoItem::GetBobbleRect() const
{
	return m_bobbleRect;
}

void InfoItem::SetBobbleRect(const QRectF &bobbleRect)
{
	m_bobbleRect = bobbleRect;
}

////////////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////////////

ChatMsgWidget::ChatMsgWidget(QWidget *parent)
	: QWidget(parent)
{
	initVars();
	initSettings();
}

ChatMsgWidget::~ChatMsgWidget()
{
	clearAllMessages();
}

void ChatMsgWidget::addItem(InfoItem *item)
{
	m_ifiColl.push_front(item);
	m_currIndex = 0;
	update();
}

void ChatMsgWidget::addItems(QVector<InfoItem *> items)
{
	m_ifiColl.clear();
	m_ifiColl = items;
	m_currIndex = 0;
	update();
}

void ChatMsgWidget::clearAllMessages()
{
	for (int k = 0; k < m_ifiColl.size(); ++k)
	{
		InfoItem* p = m_ifiColl[k];
		delete p;
	}

	m_ifiColl.clear();
}

void ChatMsgWidget::clear()
{
	clearAllMessages();

	m_currIndex = 0;
	m_VisibleItemCnt = 0;
	m_ItemCounter = 0;

	m_bAllJobsDone = false;

	update();
}

void ChatMsgWidget::render()
{
	update();
}

void ChatMsgWidget::paintEvent(QPaintEvent *)
{
	QPainter painter(this);

	painter.setRenderHints(QPainter::HighQualityAntialiasing | QPainter::Antialiasing);
	drawBackground(&painter);
	drawItems(&painter);
}

void ChatMsgWidget::mouseMoveEvent(QMouseEvent *e)
{
	int nItemY = ITEM_SPACE;

	if (m_currIndex < 0)
	{
		m_currIndex = 0;
	}

	for (int nIndex = m_currIndex; nIndex < m_ifiColl.count(); nIndex++)
	{
		if (nItemY > this->height()) 
		{
			break;
		}

		int nY = this->height() - nItemY;
		QRectF bubbleRect = m_ifiColl.at(nIndex)->GetBobbleRect();
		if ((e->pos().y() < (nY) && (e->pos().y() > (nY - bubbleRect.height()))) &&
			((e->pos().x() > bubbleRect.x()) &&
			(e->pos().x() < (bubbleRect.x() + bubbleRect.width()))))
		{
			quint8 nType = m_ifiColl.at(nIndex)->GetMsgType();

			// 如果是图片或文件，可以直接打开
			if (Picture == nType || Files == nType) {
				this->setCursor(Qt::PointingHandCursor);
				m_bHover = true;
				m_nHoverItemIndex = nIndex;
				update();
				return;
			}
		}

		// 如果有改变，需要改变回来
		if (m_bHover) 
		{
			m_bHover = false;
			m_nHoverItemIndex = -1;
			update();
			return;
		}
		nItemY += bubbleRect.height() + ITEM_SPACE;
	}

	this->setCursor(Qt::ArrowCursor);
}

void ChatMsgWidget::mousePressEvent(QMouseEvent *e)
{
	if (Qt::RightButton == e->button()) 
	{
		int nItemY = ITEM_SPACE;

		for (int nIndex = m_currIndex; nIndex < m_ifiColl.count(); nIndex++)
		{
			if (nItemY > this->height()) 
			{
				break;
			}

			int nY = this->height() - nItemY; ;
			int nRight = 0;
			if (m_ifiColl.at(nIndex)->GetOrientation() == Right)
			{
				nRight = 20;
			}
			int npos = e->pos().y();

			QRectF bubbleRect = m_ifiColl.at(nIndex)->GetBobbleRect();

			if (((e->pos().y() < (nY)) &&
				(e->pos().y() + nRight > (nY - bubbleRect.height()))
				)
				&&
				((e->pos().x() > bubbleRect.x()) &&
				(e->pos().x() < (bubbleRect.x() + bubbleRect.width()))
					)
				)
			{
				// 当前选中item
				m_selectedIndex = nIndex;

				// 如果是图片或文件，可以直接打开
				if (Picture == m_ifiColl.at(nIndex)->GetMsgType()) 
				{
					picRightButtonMenu->popup(e->globalPos());
					return;
				}
				else if (Files == m_ifiColl.at(nIndex)->GetMsgType()) 
				{
					fileRightButtonMenu->popup(e->globalPos());
					return;
				}
				else if (Text == m_ifiColl.at(nIndex)->GetMsgType()) 
				{
					textRightButtonMenu->popup(e->globalPos());
					return;
				}
			}

			nItemY += bubbleRect.height() + ITEM_SPACE;
		}
	}
}

void ChatMsgWidget::mouseDoubleClickEvent(QMouseEvent *e)
{
	int nItemY = ITEM_SPACE;

	for (int nIndex = m_currIndex; nIndex < m_ifiColl.count(); nIndex++)
	{
		if (nItemY > this->height()) 
		{
			break;
		}

		int nY = this->height() - nItemY;
		QRectF bubbleRect = m_ifiColl.at(nIndex)->GetBobbleRect();
		if ((e->pos().y() < (nY) && (e->pos().y() > (nY - bubbleRect.height()))) &&
			((e->pos().x() > bubbleRect.x()) &&
			(e->pos().x() < (bubbleRect.x() + bubbleRect.width()))))
		{
			// 如果是图片或文件，可以直接打开
			if (Picture == m_ifiColl.at(nIndex)->GetMsgType() /*|| Files == m_ifiColl.at(nIndex)->GetMsgType()*/)
			{
				QString strFile = m_ifiColl.at(nIndex)->GetText();
				// 如果文件存在，可以打开
				if (QFile::exists(strFile)) 
				{
					QDesktopServices::openUrl(QUrl::fromLocalFile(strFile));
				}

				return;
			}

			Q_EMIT sig_itemClicked(m_ifiColl.at(nIndex)->GetText());
			break;
		}
		nItemY += bubbleRect.height() + ITEM_SPACE;
	}
}

void ChatMsgWidget::resizeEvent(QResizeEvent *)
{
	calcGeo();
}

void ChatMsgWidget::leaveEvent(QEvent *)
{
	m_HoverRect = QRectF();

	//    update();
}

void ChatMsgWidget::showEvent(QShowEvent *)
{
	calcGeo();
}

void ChatMsgWidget::wheelEvent(QWheelEvent *e)
{
	if (e->delta() > 0)
	{
		wheelUp();
	}
	else 
	{
		wheelDown();
	}
}

void ChatMsgWidget::drawBackground(QPainter *painter)
{
	painter->save();
	painter->setPen(Qt::NoPen);

#if 0
	QLinearGradient BgGradient(QPoint(0, 0), QPoint(0, height()));
	BgGradient.setColorAt(0.0, QColor("#EDF5E2"));
	BgGradient.setColorAt(1.0, QColor("#C9E6D8"));
	painter->setBrush(BgGradient);
#else
	painter->setBrush(QBrush(QColor(245, 245, 245)));
#endif

	painter->drawRect(rect());
	painter->restore();
}

void ChatMsgWidget::drawItems(QPainter *painter)
{
	if (m_ifiColl.empty())
		return;

	painter->save();

	qreal nItemY = 0;
	int nWidth = this->width();
	nWidth = (0 == nWidth % 2) ? nWidth : nWidth + 1;

	nItemY = ITEM_SPACE + ITEM_TITLE_HEIGHT;

	for (int nIndex = m_currIndex; nIndex < m_ifiColl.count(); nIndex++)
	{
		if (nItemY > this->height()) 
		{
			break;
		}

		QString strMsg = m_ifiColl.at(nIndex)->GetText();
		quint8 msgType = m_ifiColl.at(nIndex)->GetMsgType();

		quint8 nOrientation = m_ifiColl.at(nIndex)->GetOrientation();
		QString strPixmap = m_ifiColl.at(nIndex)->GetStrPixmap();

		qreal bubbleWidth = 0;
		qreal bubbleHeight = 0;
		
		int nX = 0;
		int nY = 0;

		QPixmap pixmap;
		QPainterPath path;
		
		QRectF msgRect;
		QRectF bobbleRect;
		QRectF TimeRect;

		switch (msgType) 
		{
		case Text:
		{
			QFontMetrics fm(m_font);

			bubbleWidth = fm.width(strMsg);
			bubbleHeight = fm.height();

			QStringList strMsgList = strMsg.split("\n");
			qreal nLineWidth = 0;
			qreal nLineHeight = 0;

			for (int i = 0; i < strMsgList.size(); i++) 
			{
				if (nLineWidth < fm.width(strMsgList.at(i)))
				{
					nLineWidth = fm.width(strMsgList.at(i));
					nLineWidth = nLineWidth < (nWidth * 2 / 3) ? nLineWidth : (nWidth * 2 / 3);
				}

				double dLineNum = bubbleWidth / nLineWidth;// (((nLineWidth / ((nWidth * 2 / 3))) + 1) * ITEM_HEIGHT / 3);
				int nLineNum = (int)dLineNum;
				int nLineHeightTemp = nLineNum * (fm.height() * 1.25);
				nLineHeight = nLineWidth < (nWidth * 2 / 3) ? fm.height() * 1.15 : nLineHeightTemp;
				bubbleHeight += nLineHeight;
			}

			bubbleWidth = nLineWidth;
#if 0
			//            bubbleHeight = bubbleWidth < (nWidth * 2 / 3) ? ITEM_HEIGHT : (((bubbleWidth / ((nWidth * 2 / 3))) + 1) * ITEM_HEIGHT / 2);
			//            bubbleWidth = bubbleWidth < (nWidth * 2 / 3) ? bubbleWidth: (nWidth * 2 / 3);
			//            bubbleWidth = bubbleWidth < 30 ? 30 : bubbleWidth;
#endif

			// 文字初始化高度
			nY = this->height() - nItemY - bubbleHeight;
		}
		break;
		case Audio:

			break;
		case DateTime:
		{
			nY = this->height() - nItemY - 20;
		}
		break;
		case Picture:
		{
			pixmap = QPixmap(strMsg);
			if (pixmap.isNull()) 
			{
				pixmap = QPixmap(":/resource/background/ic_picture.png");
			}
			// 图片过大限制
			if (pixmap.width() > 200 || pixmap.height() > 100)
			{
				int nSmall = pixmap.width() / 200;
				pixmap = pixmap.scaled(pixmap.width() / nSmall, pixmap.height() / nSmall);
			}

			bubbleWidth = pixmap.width();
			bubbleHeight = pixmap.height() + 10;

			// 文字初始化高度
			nY = this->height() - nItemY - bubbleHeight;

		}
		break;
		case Files:
		{
			QFileInfo fileInfo(strMsg);
			QString strSize = m_ifiColl.at(nIndex)->GetFileSizeString();

			// 文件图标

			pixmap = QPixmap(":/resource/images/ic_zip.png");

			// 先判断文件是否存在
			if (QFile::exists(strMsg)) 
			{
				strSize = "文件大小: ";
				strSize += helper::CalcSize(fileInfo.size());
#ifdef Q_OS_WIN32
				QFileIconProvider provider;
				QIcon icon = provider.icon(fileInfo);
				pixmap = icon.pixmap(48, 48);
#endif
			}
			else 
			{
				strSize = "文件未下载 ";
			}

			QFont font("微软雅黑", 10);
			QFontMetrics fm(font);
			
			strMsg = fileInfo.fileName();
			
			if (fm.width(strMsg) < fm.width(strSize)) 
			{
				bubbleWidth = fm.width(strSize) + pixmap.width() + 20;
			}
			else 
			{
				bubbleWidth = fm.width(strMsg) + pixmap.width() + 20;
			}

			bubbleHeight = 60;

			bubbleWidth = bubbleWidth < (nWidth * 2 / 3) ? bubbleWidth : (nWidth * 2 / 3);
			bubbleWidth = bubbleWidth < 60 ? 60 : bubbleWidth;

			strMsg += "\n";
			strMsg += strSize;

			nY = this->height() - nItemY - bubbleHeight;
		}
		break;
		default:
			break;
		}

		if (Right == nOrientation)
		{
			painter->save();
			painter->setPen(QPen(QColor("#D3D3D3"), 1));
			
			painter->drawRoundedRect(nWidth - 55, nY, 50, 50, 2, 2);
			
			QPixmap pixmap(strPixmap);
			if (!pixmap.isNull()) 
			{
				painter->drawPixmap(nWidth - 55 + 1, nY + 1, 48, 48, pixmap);
			}
			painter->restore();
			painter->save();
			
			QFont font("微软雅黑", 8);
			QFontMetrics fm(font);
			QString strTitle = m_ifiColl.at(nIndex)->GetName();

			painter->setPen(QColor("#666666"));
			painter->setFont(font);
			painter->drawText(nWidth - 55 - fm.width(strTitle) - 20, nY + fm.height() / 2, strTitle);
			painter->restore();

			nX = (nWidth)-95 - bubbleWidth;
			if (nX < 0) 
			{
				nX = -bubbleWidth - 95 + nWidth;
			}

			nY += ITEM_TITLE_HEIGHT;
			bobbleRect = QRectF(nX, nY, bubbleWidth + 20, bubbleHeight);
			msgRect = QRectF(nX + 10, nY, bubbleWidth, bubbleHeight);

			painter->save();
			
			path.addRoundedRect(bobbleRect, 10, 10);
			path.moveTo(nWidth - 75, nY + 15);
			path.lineTo(nWidth - 65, nY + 20);
			path.lineTo(nWidth - 75, nY + 25);
			//            painter->fillPath(path, itemGradient);
			painter->setPen(Qt::red);
			painter->fillPath(path, QColor("#FFFFFF"));
			painter->restore();
		}
		else if (Left == nOrientation)
		{
			painter->save();
			painter->setPen(QColor("#D3D3D3"));
			
			painter->drawRoundedRect(5, nY, 50, 50, 2, 2);

			QPixmap pixmap(strPixmap);
			if (!pixmap.isNull()) 
			{
				painter->drawPixmap(6, nY + 1, 48, 48, pixmap);
			}

			painter->restore();

			nX = 75;
			
			painter->save();
			
			QFont font("微软雅黑", 8);
			QFontMetrics fm(font);

			QString strTitle = m_ifiColl.at(nIndex)->GetName();// + " ";
			//strTitle += m_ifiColl.at(nIndex)->GetDatetime();

			painter->setPen(QColor("#666666"));
			painter->setFont(font);
			painter->drawText(nX, nY + fm.height() / 2, strTitle);
			painter->restore();

			painter->save();
			nY += ITEM_TITLE_HEIGHT;
			bobbleRect = QRectF(nX, nY, bubbleWidth + 20, bubbleHeight);
			
			msgRect = QRectF(nX + 10, nY, bubbleWidth, bubbleHeight);

			path.addRoundedRect(bobbleRect, 5, 5);
			path.moveTo(nX, nY + 15);
			path.lineTo(nX - 10, nY + 20);
			path.lineTo(nX, nY + 25);
			
			painter->fillPath(path, QColor("#9EE656"));
			painter->restore();
		}
		else
		{
			painter->save();
			
			QFont font("微软雅黑", 8);
			QFontMetrics fm(font);
			QString strTitle = m_ifiColl.at(nIndex)->GetDatetime();

			nY += ITEM_TITLE_HEIGHT;
			TimeRect = QRect(0, nY, nWidth, 20);

			painter->setPen(QColor("#666666"));
			painter->setFont(font);
			painter->drawText(TimeRect, Qt::AlignCenter, strTitle);
			painter->restore();
		}

		painter->setPen(QColor("#000000"));
		painter->setFont(m_font);

		if (Text == msgType) 
		{
			painter->drawText(msgRect, strMsg, Qt::AlignVCenter | Qt::AlignLeft);
		}
		else if (Picture == msgType) 
		{
			//            QMovie *movie = new QMovie("d:/01.gif");
			//            for (int i=0;i<movie->frameCount();i++)
			//            {
			//                movie->jumpToFrame(i);
			//                QImage image = movie->currentImage();
			//                //painter->drawImage(nX + 10, nY + 5,pixmap.width(), pixmap.height(),&image);
			//                //myHelper::Sleep(1);
			//                painter->drawPixmap(nX + 10, nY + 5, pixmap.width(), pixmap.height(), QPixmap::fromImage(image));
			//            }

			painter->drawPixmap(nX + 10, nY + 5, pixmap.width(), pixmap.height(), pixmap);

		}
		else if (DateTime == msgType) 
		{
			//painter->drawPixmap(nX + 10, nY + 5, pixmap.width(), pixmap.height(), pixmap);
		}
		else if (Files == msgType) 
		{
			painter->drawPixmap(nX + 10, nY + 5 + (48 - pixmap.height()) / 2, pixmap.width(), pixmap.height(), pixmap);
			msgRect.setX(msgRect.x() + pixmap.width() + 15);
			painter->save();
			painter->setPen(Qt::blue);
			QFont font("微软雅黑", 10);
			font.setUnderline(m_bHover && (nIndex == m_nHoverItemIndex));
			painter->setFont(font);
			painter->drawText(msgRect, strMsg, Qt::AlignVCenter | Qt::AlignLeft);
			painter->restore();
		}

		m_ifiColl.at(nIndex)->SetBobbleRect(bobbleRect);
		nItemY += (bobbleRect.height()) + ITEM_SPACE + ITEM_TITLE_HEIGHT;
	}
	painter->restore();
}

void ChatMsgWidget::initVars()
{
	m_currIndex = 0;
	m_VisibleItemCnt = 0;
	m_ItemCounter = 0;

	m_bAllJobsDone = false;
	m_bHover = false;

	m_font = QFont("楷体", 12);

	// 右键菜单
	textRightButtonMenu = new QMenu(this);
	//    textRightButtonMenu->addAction("保存图片");
	//    textRightButtonMenu->addSeparator();
	textRightButtonMenu->addAction(ZN_STR("复制文本"));
	textRightButtonMenu->hide();
	connect(textRightButtonMenu, SIGNAL(triggered(QAction*)), this, SLOT(SltTextMenuClicked(QAction*)));

	// 右键菜单
	picRightButtonMenu = new QMenu(this);
	picRightButtonMenu->addAction(ZN_STR("保存图片"));
	picRightButtonMenu->addSeparator();
	picRightButtonMenu->addAction(ZN_STR("复制到粘贴板"));
	picRightButtonMenu->hide();

	// 右键菜单
	fileRightButtonMenu = new QMenu(this);
	//    fileRightButtonMenu->addAction("下载文件");
	//    fileRightButtonMenu->addSeparator();
	fileRightButtonMenu->addAction(ZN_STR("打开文件"));
	fileRightButtonMenu->addAction(ZN_STR("打开文件目录"));
	fileRightButtonMenu->hide();

	connect(fileRightButtonMenu, SIGNAL(triggered(QAction*)), this, SLOT(SltFileMenuClicked(QAction*)));
}

void ChatMsgWidget::initSettings()
{
	setMouseTracking(true);
}

void ChatMsgWidget::calcGeo()
{
#if 0
	// 计算当前可以刷新的item个数
	qDebug() << "calc Geo" << m_currIndex;
	int nCnt = 0;
	int nHeight = 0;
	int nCurrIndex = m_currIndex;

	while (nCurrIndex > 1) 
	{
		nHeight = m_ifiColl.at(nCurrIndex)->getItemHeight();
		nHeight += ITEM_SPACE;
		if (nHeight + 20 >= this->height()) 
			break;
		nCnt++;
		nCurrIndex--;
	}

	m_VisibleItemCnt = nCnt;
	//    m_currIndex = nCurrIndex - nCnt;
#else
	m_VisibleItemCnt = height() / (ITEM_HEIGHT + ITEM_SPACE + 10) + 1;
#endif

	int InvisibleItemCnt = m_ifiColl.count() - m_VisibleItemCnt;

	if (InvisibleItemCnt >= 0)
	{
		emit sig_setMaximum(InvisibleItemCnt);
	}
}

void ChatMsgWidget::wheelUp()
{
	m_currIndex++;

	if (m_currIndex > m_ifiColl.size()) 
	{
		m_currIndex = m_ifiColl.size() - 1;
	}

	update();
	emit sig_setCurrentIndex(m_currIndex);
}

void ChatMsgWidget::wheelDown()
{
	m_currIndex--;

	if (m_currIndex < 0)
	{
		m_currIndex = 0;
	}

	update();
	emit sig_setCurrentIndex(m_currIndex);
}

void ChatMsgWidget::SltFileMenuClicked(QAction *action)
{
	QString strText = m_ifiColl.at(m_selectedIndex)->GetText();
	QFileInfo fileInfo(strText);

	if (action->text() == ZN_STR("下载文件"))
	{
		if (QFile::exists(strText)) 
		{
			QDesktopServices::openUrl(QUrl::fromLocalFile(fileInfo.absolutePath()));
			return;
		}

		Q_EMIT signalDownloadFile(fileInfo.fileName());
	}
	else if (action->text() == ZN_STR("打开文件"))
	{
		if (QFile::exists(strText)) 
		{
			QDesktopServices::openUrl(QUrl::fromLocalFile(strText));
			return;
		}
	}
	else if (action->text() == ZN_STR("打开文件目录"))
	{
		QDesktopServices::openUrl(QUrl::fromLocalFile(fileInfo.absolutePath()));
	}
}

void ChatMsgWidget::SltTextMenuClicked(QAction *action)
{
	QString strText = m_ifiColl.at(m_selectedIndex)->GetText();
	
	if (action->text() == ZN_STR("复制文本"))
	{
		QClipboard *clipboard = QApplication::clipboard();
		clipboard->setText(strText);		 
	}
}

void ChatMsgWidget::setCurrentIndex(int curIndex)
{
	if (curIndex == m_currIndex)
	{
		return;
	}

	//
	m_currIndex = m_ifiColl.size() - curIndex;
	if ((m_ifiColl.size() - 1) < 50)
	{
		m_currIndex = 50 - curIndex;
	}

	if (m_currIndex > m_ifiColl.size()) 
	{
		m_currIndex = m_ifiColl.size() - 1;
	}
	if (m_currIndex < 0)
	{
		m_currIndex = 0;
	}

	update();
	//emit sig_setCurrentIndex(m_currIndex);
}

////////////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////////////

ChatMsgDisplayWidget::ChatMsgDisplayWidget(QWidget *parent)
	: QWidget(parent)
{
	initVars();
	initWgts();
	initStgs();
	initConns();
}

ChatMsgDisplayWidget::~ChatMsgDisplayWidget()
{
	d->clear();
}

void ChatMsgDisplayWidget::dispMsg(const QString& strName, const string& strMsg, int flag)
{
	QString text = strMsg.data();
	QChar qcSlit = (QChar)(0xfffc);
	QStringList textList = text.split(qcSlit);

	while (text.endsWith("\n"))
	{
		text.remove(text.length() - 1, 1);
	}

	bool bNeedShowTime = false;
	if (m_lastShowMsgTime.isNull())
	{
		m_lastShowMsgTime = QDateTime::currentDateTime();
		bNeedShowTime = true;
	}
	else
	{
		qint64 nTimeSub = m_lastShowMsgTime.msecsTo(QDateTime::currentDateTime());
		int nMinute = nTimeSub / 60000;

		if (nMinute > 3)
		{
			bNeedShowTime = true;
		}

		m_lastShowMsgTime = QDateTime::currentDateTime();
	}

	if (bNeedShowTime)
	{
		InfoItem *itemTime = new InfoItem();
		itemTime->SetDatetime(DATE_TIME);
		itemTime->SetMsgType(DateTime);
		itemTime->SetOrientation(None);

		addItem(itemTime);
	}

	////检查是否有图片，有的话，先发送图片
	//for (int i = 0; i < m_sAcPicList.size(); i++)
	//{
	//	//构建气泡消息:图片
	//	InfoItem *picitemInfo = new InfoItem();
	//	picitemInfo->SetName("lanzhiyu");
	//	picitemInfo->SetDatetime(DATE_TIME);
	//	picitemInfo->SetHeadPixmap(":/images/1.png");
	//	picitemInfo->SetText(m_sAcPicList[i]);
	//	picitemInfo->SetOrientation(Right);
	//	picitemInfo->SetMsgType(Picture);

	//	// 加入聊天界面
	//	addItem(picitemInfo);
	//}

	////检查是否有文件，有的话，发送文件
	//for (int i = 0; i < m_sAcFileList.size(); i++)
	//{
	//	//构建气泡消息:文件
	//	InfoItem *FileitemInfo = new InfoItem();
	//	FileitemInfo->SetName("lanzhiyu");
	//	FileitemInfo->SetDatetime(DATE_TIME);
	//	FileitemInfo->SetHeadPixmap(":/images/1.png");

	//	QFileInfo fileInfo(m_sAcFileList[i]);
	//	int lasl = fileInfo.size();

	//	FileitemInfo->SetText(m_sAcFileList[i]);
	//	FileitemInfo->SetFileSizeString(QString::number(fileInfo.size()));
	//	FileitemInfo->SetOrientation(Right);
	//	FileitemInfo->SetMsgType(Files);

	//	// 加入聊天界面
	//	addItem(FileitemInfo);
	//}

	int nEmptyNum = 0;

	if (0 == flag)
	{
		for (int i = 0; i < textList.size(); i++)
		{
			if (textList[i].isEmpty())
			{
				nEmptyNum++;
				continue;
			}
			// 构建气泡消息
			InfoItem *itemInfo = new InfoItem();
			itemInfo->SetName(strName);
			itemInfo->SetDatetime(DATE_TIME);
			itemInfo->SetHeadPixmap(":/images/5.png");
			itemInfo->SetText(textList[i]);
			itemInfo->SetOrientation(Right);

			// 加入聊天界面
			addItem(itemInfo);
		}
	}
	else if (1 == flag)
	{
		for (int i = 0; i < textList.size(); i++)
		{
			if (textList[i].isEmpty())
			{
				nEmptyNum++;
				continue;
			}
			// 构建气泡消息
			InfoItem *itemInfo = new InfoItem();
			itemInfo->SetName(strName);
			itemInfo->SetDatetime(DATE_TIME);
			itemInfo->SetHeadPixmap(":/images/6.png");
			itemInfo->SetText(textList[i]);
			itemInfo->SetOrientation(Left);

			// 加入聊天界面
			addItem(itemInfo);
		}
	}
	else if (2 == flag)
	{
		for (int i = 0; i < textList.size(); i++)
		{
			if (textList[i].isEmpty())
			{
				nEmptyNum++;
				continue;
			}
			// 构建气泡消息
			InfoItem *itemInfo = new InfoItem();
			itemInfo->SetName(strName);
			itemInfo->SetDatetime(DATE_TIME);
			itemInfo->SetHeadPixmap(":/images/7.png");
			itemInfo->SetText(textList[i]);
			itemInfo->SetOrientation(Left);

			// 加入聊天界面
			addItem(itemInfo);
		}
	}

	//if (textList.size() > 0)
	//{
	//	//模拟收信息
	//	InfoItem *itemInfo2 = new InfoItem();
	//	itemInfo2->SetName("bluesky");
	//	itemInfo2->SetDatetime(DATE_TIME);
	//	itemInfo2->SetHeadPixmap(":/images/2.png");

	//	//QString sMsg = QString("Text msg num=%1,Picture num=%2,Files num=%3").arg(textList.size()-nEmptyNum).arg(m_sAcPicList.size()).arg(m_sAcFileList.size());
	//	QString sMsg = QString("收到你发送的文字消息数：%1，图片数:%2，文件数:%3").arg(textList.size() - nEmptyNum).arg(m_sAcPicList.size()).arg(m_sAcFileList.size());
	//	itemInfo2->SetText(sMsg);
	//	itemInfo2->SetOrientation(Left);

	//	addItem(itemInfo2);
	//}
}

void ChatMsgDisplayWidget::addItem(InfoItem *item)
{
	d->addItem(item);
}

void ChatMsgDisplayWidget::addItems(QVector<InfoItem *> items)
{
	if (items.size() < 1) 
		return;

	d->addItems(items);
}

void ChatMsgDisplayWidget::clear()
{
	d->clear();
}

void ChatMsgDisplayWidget::render()
{
	d->render();
}

void ChatMsgDisplayWidget::setCurrItem(const int &index)
{
	scrollbar->setValue(index);
}

void ChatMsgDisplayWidget::resizeEvent(QResizeEvent *)
{

}

void ChatMsgDisplayWidget::initVars()
{
}

void ChatMsgDisplayWidget::initWgts()
{
	mainLayout = new QHBoxLayout(this);
	scrollbar = new QScrollBar(this);
	d = new ChatMsgWidget(this);
	this->setMinimumWidth(300);

	mainLayout->addWidget(d);
	//mainLayout->addWidget(m_pSlider);
	mainLayout->addWidget(scrollbar);
	setLayout(mainLayout);
}

void ChatMsgDisplayWidget::initStgs()
{
	mainLayout->setContentsMargins(0, 0, 0, 0);
	mainLayout->setSpacing(0);

	scrollbar->setStyleSheet("QScrollBar:vertical"
		"{"
		"width:8px;"
		"background:rgba(0,0,0,0%);"
		"margin:0px,0px,0px,0px;"
		"padding-top:9px;"
		"padding-bottom:9px;"
		"}"
		"QScrollBar::handle:vertical"
		"{"
		"width:8px;"
		"background:rgba(0,0,0,25%);"
		" border-radius:4px;"
		"min-height:20;"
		"}"
		"QScrollBar::handle:vertical:hover"
		"{"
		"width:8px;"
		"background:rgba(0,0,0,50%);"
		" border-radius:4px;"
		"min-height:20;"
		"}"
		"QScrollBar::add-line:vertical"
		"{"
		"height:9px;width:8px;"
		"border-image:url(:/images/a/3.png);"
		"subcontrol-position:bottom;"
		"}"
		"QScrollBar::sub-line:vertical"
		"{"
		"height:9px;width:8px;"
		"border-image:url(:/images/a/1.png);"
		"subcontrol-position:top;"
		"}"
		"QScrollBar::add-line:vertical:hover"
		"{"
		"height:9px;width:8px;"
		"border-image:url(:/images/a/4.png);"
		"subcontrol-position:bottom;"
		"}"
		"QScrollBar::sub-line:vertical:hover"
		"{"
		"height:9px;width:8px;"
		"border-image:url(:/images/a/2.png);"
		"subcontrol-position:top;"
		"}"
		"QScrollBar::add-page:vertical,QScrollBar::sub-page:vertical"
		"{"
		"background:rgba(0,0,0,10%);"
		"border-radius:4px;"
		"}"
	);

	scrollbar->setRange(0, 0);
	scrollbar->setValue(scrollbar->maximum());
	scrollbar->show();

	//scrollbar->hide();
}

void ChatMsgDisplayWidget::initConns()
{
	connect(scrollbar, SIGNAL(valueChanged(int)), d, SLOT(setCurrentIndex(int)));
	connect(d, SIGNAL(sig_setMaximum(int)), this, SLOT(setMaximum(int)));
	connect(d, SIGNAL(sig_setCurrentIndex(int)), scrollbar, SLOT(setValue(int)));
	connect(d, SIGNAL(sig_itemClicked(QString)), this, SIGNAL(sig_itemClicked(QString)));
	connect(d, SIGNAL(signalDownloadFile(QString)), this, SIGNAL(signalDownloadFile(QString)));
}

void ChatMsgDisplayWidget::calcGeo()
{

}

void ChatMsgDisplayWidget::setMaximum(int max)
{
	if (max == 0)
	{
		scrollbar->hide();
	}
	else 
	{
		scrollbar->show();
	}

	scrollbar->setRange(0, max);
}

////////////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////////////

