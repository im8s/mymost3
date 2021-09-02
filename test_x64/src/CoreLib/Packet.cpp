#include "Packet.h"

#include <google/protobuf/descriptor.h>
#include <google/protobuf/message.h>
//#include <zlib.h>  // adler32

//#include <string>

//#include <arpa/inet.h>  // htonl, ntohl
#include <stdint.h>

const int kHeaderLen = sizeof(int32_t);

////////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////////

#define BigLittleSwap16(A)  ((((uint16)(A) & 0xff00) >> 8) | (((uint16)(A) & 0x00ff) << 8))
#define BigLittleSwap32(A)  ((((uint32)(A) & 0xff000000) >> 24) | (((uint32)(A) & 0x00ff0000) >> 8) \
							| (((uint32)(A) & 0x0000ff00) << 8) | (((uint32)(A) & 0x000000ff) << 24))

// 本机大端返回1，小端返回0
int checkCPUendian()
{
	union {
		unsigned long int i;
		unsigned char s[4];
	}c;

	c.i = 0x12345678;

	return (0x12 == c.s[0]);
}

unsigned long int _htonl(unsigned long int h)
{
	return checkCPUendian() ? h : BigLittleSwap32(h);
}

unsigned long int _ntohl(unsigned long int n)
{
	return checkCPUendian() ? n : BigLittleSwap32(n);
}

unsigned short int _htons(unsigned short int h)
{
	return checkCPUendian() ? h : BigLittleSwap16(h);
}

unsigned short int _ntohs(unsigned short int n)
{
	return checkCPUendian() ? n : BigLittleSwap16(n);
}

#if 1

const int MOD_ADLER = 65521;

uint32_t adler32(unsigned char *data, int32_t len)
{
	uint32_t a = 1, b = 0;
	int32_t index;

	for (index = 0; index < len; ++index)
	{
		a = (a + data[index]) % MOD_ADLER;
		b = (b + a) % MOD_ADLER;
	}

	return (b << 16) | a;
}

#else

static const unsigned long BASE = 65521;
static const unsigned int NMAX = 5552;

#define DO1(buf,i)  {adler += (buf)[i]; sum2 += adler;}
#define DO2(buf,i)  DO1(buf,i); DO1(buf,i+1);
#define DO4(buf,i)  DO2(buf,i); DO2(buf,i+2);
#define DO8(buf,i)  DO4(buf,i); DO4(buf,i+4);
#define DO16(buf)   DO8(buf,0); DO8(buf,8);

#ifdef NO_DIVIDE
#  define MOD(a) \
    do { \
        if (a >= (BASE << 16)) a -= (BASE << 16); \
        if (a >= (BASE << 15)) a -= (BASE << 15); \
        if (a >= (BASE << 14)) a -= (BASE << 14); \
        if (a >= (BASE << 13)) a -= (BASE << 13); \
        if (a >= (BASE << 12)) a -= (BASE << 12); \
        if (a >= (BASE << 11)) a -= (BASE << 11); \
        if (a >= (BASE << 10)) a -= (BASE << 10); \
        if (a >= (BASE << 9)) a -= (BASE << 9); \
        if (a >= (BASE << 8)) a -= (BASE << 8); \
        if (a >= (BASE << 7)) a -= (BASE << 7); \
        if (a >= (BASE << 6)) a -= (BASE << 6); \
        if (a >= (BASE << 5)) a -= (BASE << 5); \
        if (a >= (BASE << 4)) a -= (BASE << 4); \
        if (a >= (BASE << 3)) a -= (BASE << 3); \
        if (a >= (BASE << 2)) a -= (BASE << 2); \
        if (a >= (BASE << 1)) a -= (BASE << 1); \
        if (a >= BASE) a -= BASE; \
    } while (0)
#  define MOD4(a) \
    do { \
        if (a >= (BASE << 4)) a -= (BASE << 4); \
        if (a >= (BASE << 3)) a -= (BASE << 3); \
        if (a >= (BASE << 2)) a -= (BASE << 2); \
        if (a >= (BASE << 1)) a -= (BASE << 1); \
        if (a >= BASE) a -= BASE; \
    } while (0)
#else
#  define MOD(a) (a %= BASE)
#  define MOD4(a) (a %= BASE)
#endif

unsigned int adler32(const unsigned char *buf, unsigned int len)
{
	unsigned long adler = 1;
	unsigned long sum2 = 0;
	unsigned int n;

	if (NULL == buf)
		return adler;

	if (len == 1) 
	{
		adler += buf[0];
		if (adler >= BASE)
			adler -= BASE;
		sum2 += adler;
		if (sum2 >= BASE)
			sum2 -= BASE;
		return adler | (sum2 << 16);
	}

	if (len < 16) 
	{
		while (len--) 
		{
			adler += *buf++;
			sum2 += adler;
		}
		if (adler >= BASE)
			adler -= BASE;
		MOD4(sum2);
		return adler | (sum2 << 16);
	}

	while (len >= NMAX) 
	{
		len -= NMAX;
		n = NMAX / 16;
		do 
		{
			DO16(buf);
			buf += 16;

		}	while (--n);

		MOD(adler);
		MOD(sum2);
	}

	if (len) 
	{
		while (len >= 16) 
		{
			len -= 16;
			DO16(buf);
			buf += 16;
		}

		while (len--) 
		{
			adler += *buf++;
			sum2 += adler;
		}

		MOD(adler);
		MOD(sum2);
	}

	return (unsigned int)(adler | (sum2 << 16));
}

#endif

bool encode(string& strData, const Message& message)
{
	strData.resize(kHeaderLen);

	const string& typeName = message.GetTypeName();
	int32_t nameLen = static_cast<int32_t>(typeName.size() + 1);
	int32_t be32 = _htonl(nameLen);
	strData.append(reinterpret_cast<char*>(&be32), sizeof be32);
	strData.append(typeName.c_str(), nameLen);

	bool succeed = message.AppendToString(&strData);
	if (succeed)
	{
		const char* begin = strData.c_str() + kHeaderLen;
		int32_t checkSum = adler32( (unsigned char *)begin, strData.size() - kHeaderLen );
		int32_t be32 = _htonl(checkSum);
		strData.append(reinterpret_cast<char*>(&be32), sizeof be32);

		int32_t len = _htonl(strData.size() - kHeaderLen);
		std::copy(reinterpret_cast<char*>(&len),reinterpret_cast<char*>(&len) + sizeof len, strData.begin());
	}
	
	return succeed;
}

Message* createMessage(const string& type_name)
{
	Message* message = NULL;

	const Descriptor* descriptor = DescriptorPool::generated_pool()->FindMessageTypeByName(type_name);
	if (descriptor)
	{
		const Message* prototype = MessageFactory::generated_factory()->GetPrototype(descriptor);
		if (prototype)
		{
			message = prototype->New();
		}
	}

	return message;
}

inline int32_t asInt32(const char* buf)
{
	int32_t be32 = 0;
	::memcpy(&be32, buf, sizeof(be32));

	return _ntohl(be32);
}

Message* decode(const string& buf)
{
	Message* result = NULL;

	int32_t len = static_cast<int32_t>(buf.size());
	if (len >= 10)
	{
		int32_t expectedCheckSum = asInt32(buf.c_str() + buf.size() - kHeaderLen);
		const char* begin = buf.c_str();
		int32_t checkSum = adler32((unsigned char *)begin, len - kHeaderLen);

		if (checkSum == expectedCheckSum)
		{
			int32_t nameLen = asInt32(buf.c_str());

			if (nameLen >= 2 && nameLen <= len - 2 * kHeaderLen)
			{
				string typeName(buf.begin() + kHeaderLen, buf.begin() + kHeaderLen + nameLen - 1);

				Message* message = createMessage(typeName);
				if (message)
				{
					const char* data = buf.c_str() + kHeaderLen + nameLen;
					int32_t dataLen = len - nameLen - 2 * kHeaderLen;

					if (message->ParseFromArray(data, dataLen))
					{
						result = message;
					}
					else
					{
						delete message;
					}
				}
			}
		}
	}

	return result;
}

////////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////////

Packet::Packet(QObject *parent)
	: PacketBase(parent)
{
	
}

Packet::~Packet()
{
	
}

void Packet::parsePacket(const QByteArray& ba)
{
	m_baData += ba;

	while (!m_bQuit)
	{
		DataPacket dp;
		tMsg msg;

		if (dp.unpackData(m_baData, msg))
		{
			dispMessage(msg);
		}
		else
			break;
	}
}

bool Packet::pack(QByteArray& baData, const Message& msg)
{
	string str;
	bool b = encode(str, msg);
	if (b)
	{
		baData = QByteArray(str.data(), str.size());

		/*string str2;
		if (!msg.SerializeToString(&str2))
			return false;

		QByteArray ba = QByteArray(str2.data(), str2.size());

		int kkk = 0;*/
	}

	return b;
}

Message* Packet::unpack(const string& str)
{
	Message* msg = decode(str);
	
	return msg;
}

Message* Packet::unpack(const QByteArray& baData)
{
	string str = baData.toStdString();
	
	return unpack(str);
}

bool Packet::packPlayerLoginMsg(QByteArray& baData, qint32 msgId, const QString& strUser, const QString& strPass, int nUserType)
{
	PlayerReqMsg msg;
	msg.set_pid("");

	PlayerLogin* pj = msg.mutable_plogin();

	pj->set_name(strUser.toUtf8());
	pj->set_pass(strPass.toUtf8());
	pj->set_type(nUserType);

#if 1
	string str;
	if (!msg.SerializeToString(&str))
		return false;

	QByteArray ba = QByteArray(str.data(), str.size());

	DataPacket dp;
	dp.packData(msgId, ba);

	baData = dp.getData();

	return true;
#else
	return pack(baData, msg);
#endif
}

bool Packet::packPlayerReqMsg(QByteArray& baData, const QString& pid, qint32 msgId, int rtype)
{
	PlayerReqMsg msg;
	msg.set_pid(pid.toUtf8());

	PlayerOther* po = msg.mutable_pother();
	po->set_rtype(rtype);

#if 1
	string str;
	if (!msg.SerializeToString(&str))
		return false;

	QByteArray ba = QByteArray(str.data(), str.size());

	DataPacket dp;
	dp.packData(msgId, ba);

	baData = dp.getData();

	return true;
#else
	return pack(baData, msg);
#endif
}

bool Packet::packTalkMsg(QByteArray& baData, const QString& pid, qint32 msgId, const QString& strMsg)
{
	TalkMsg msg;
	msg.set_pid(pid.toUtf8());
	msg.set_content(strMsg.toUtf8());

#if 1
	string str;
	if (!msg.SerializeToString(&str))
		return false;

	QByteArray ba = QByteArray(str.data(), str.size());

	DataPacket dp;
	dp.packData(msgId, ba);

	baData = dp.getData();

	return true;
#else
	return pack(baData, msg);
#endif
}

bool Packet::packSysTalkMsg(QByteArray& baData, const QString& pid, qint32 msgId, const QString& strMsg)
{
	SysMsg msg;
	msg.set_pid(pid.toUtf8());
	msg.set_content(strMsg.toUtf8());

#if 1
	string str;
	if (!msg.SerializeToString(&str))
		return false;

	QByteArray ba = QByteArray(str.data(), str.size());

	DataPacket dp;
	dp.packData(msgId, ba);

	baData = dp.getData();

	return true;
#else
	return pack(baData, msg);
#endif
}

bool Packet::unpackData(QByteArray& ba, tMsgData& msg)
{
	if (ba.size() > DHEAD_LEN)
	{
		const char* ss = ba.data();
		tDataHead* h = (tDataHead*)ss;
		if (DHEAD_LEN + h->len <= ba.size())
		{
			msg.dh = (*h);
			msg.str = QByteArray(ss + sizeof(tDataHead), h->len);

			ba.remove(0, DHEAD_LEN + h->len);

			return true;
		}
	}

	return false;
}

void Packet::dispMessage(const tMsg& msg)
{
	if (99 == msg.dh.id)
	{
		processPlayerResMsg(msg.str);
	}
	else if (1 == msg.dh.id)
	{
		processTalkMsg(msg.str);
	}
	else if (3 == msg.dh.id)
	{
		processSysTalkMsg(msg.str);
	}
}

void Packet::processPlayerResMsg(const string& strData)
{
	PlayerResMsg msg;
	msg.ParseFromString(strData);

	QString pid = msg.pid().data();
	
	if (msg.has_pstatus())
	{
		const pb::PlayerState& ps = msg.pstatus();

		Q_EMIT playerState(ps.pid().data(), ps.type(), ps.code());
	}
	else if (msg.has_pinfo())
	{
		const pb::PlayerInfo& pi = msg.pinfo();

		tPlayer p;
		p.pid = pi.pid().data();
		p.strName = pi.name().data();
		p.type = pi.type();

		Q_EMIT playerEnter(p);
	}
	else if (msg.has_plist())
	{
		tPlayerRefMap piColl;
		{
			const pb::PlayerList& pilist = msg.plist();

			for (int i = 0; i < pilist.players_size(); ++i)
			{
				const pb::PlayerInfo& pi = pilist.players(i);

				{
					QString pid = pi.pid().data();
					
					if (!piColl.contains(pid))
					{
						tPlayer p;
						{
							const pb::PlayerInfo& pi = msg.pinfo();

							p.pid = pid;
							p.strName = pi.name().data();
							p.type = pi.type();
						}

						piColl[pid] = p;
					}
				}
			}
		}

		Q_EMIT setPlayerList(piColl, -1);
	}
	else if (msg.has_pjoin())
	{
		tPlayer p;
		{
			const pb::PlayerJoin& pj = msg.pjoin();
			const pb::PlayerInfo& pi = pj.pinfo();

			p.pid = pi.pid().data();
			p.strName = pi.name().data();
			p.type = pi.type();
		}

		Q_EMIT playerEnter(p);
	}
	else if (msg.has_pleave())
	{
		{
			const pb::PlayerLeave& pl = msg.pleave();

			QString pid = pl.pid().data();
			int reason = pl.reason();
		}

		Q_EMIT playerLeave(pid);
	}
}

void Packet::processTalkMsg(const string& strData)
{
	TalkMsg msg;
	msg.ParseFromString(strData);

	Q_EMIT dispTalkMsg(msg.pid().data(), msg.content().data());
}

void Packet::processSysTalkMsg(const string& strData)
{
	SysMsg msg;
	msg.ParseFromString(strData);

	Q_EMIT dispSysTalkMsg(msg.pid().data(), msg.content().data());
}

////////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////////

