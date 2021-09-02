#include "LotteryQueryGrpcClient.h"

#include "ToolFunc.h"


LotteryQueryGrpcClient::LotteryQueryGrpcClient(QObject *parent)
	: QObject(parent)
{
}

LotteryQueryGrpcClient::~LotteryQueryGrpcClient()
{
}

bool LotteryQueryGrpcClient::setParams(const QString& strIp, int port)
{
	QString str = ZN_STR("%1:%2").arg(strIp).arg(port);

	std::shared_ptr<Channel> channel = grpc::CreateChannel(str.toStdString(), grpc::InsecureChannelCredentials());
	stub_ = LotteryQuery::NewStub(channel);

	return true;
}

bool LotteryQueryGrpcClient::fetchLotteryInfo(int tp)
{
	LotteryRequest req;
	req.set_type(tp);

	ClientContext context;
	LotteryResponse res;

	Status status = stub_->FetchLotteryInfo(&context, req, &res);

	if (status.ok())
	{
		processLotteryResMsg(res);

		return true;
	}
	else
	{
		//std::cout << status.error_code() << ": " << status.error_message() << std::endl;

		return false;
	}
}

void LotteryQueryGrpcClient::processLotteryResMsg(const LotteryResponse& msg)
{
	if (msg.has_lotstatus())
	{
		const pb::LotteryState& ls = msg.lotstatus();

		Q_EMIT setLotteryState(ls.type(), ls.code());
	}
	else if (msg.has_lotserver())
	{
		const pb::LotteryServer& ls = msg.lotserver();

		tServerTime p;
		p.strServerTime = ls.servertime().data();
		p.doProcess();

		Q_EMIT setLotteryServerTime(p);
	}
	else if (msg.has_lotlist())
	{
		tLotteryRefMap lotColl;
		{
			const pb::LotteryList& lotList = msg.lotlist();

			tLottery firstLot;
			bool bIsEmpty = true;

			for (int i = 0; i < lotList.lotterys_size(); ++i)
			{
				const pb::LotteryInfo& li = lotList.lotterys(i);

				{
					QString strPeriods = li.periods().data();
					qint32 nPeriods = strPeriods.toInt();

					if (!lotColl.contains(nPeriods))
					{
						tLottery p;
						{
							p.strPeriods = li.periods().data();
							p.strBeginTime = li.begintime().data();
							p.strOpenTime = li.opentime().data();
							p.strCollectTime = li.collecttime().data();
							p.strOpenContent = li.opencontent().data();

							p.doProcess(true);
						}

						lotColl[nPeriods] = p;
					}
				}
			}
		}

		Q_EMIT setLotteryHistory(lotColl);
	}
	else if (msg.has_lotnext())
	{
		tLottery p;
		{
			const pb::LotteryNext& ln = msg.lotnext();
			const pb::LotteryInfo& li = ln.lotinfo();

			p.strPeriods = li.periods().data();
			p.strBeginTime = li.begintime().data();
			p.strOpenTime = li.opentime().data();
			p.strCollectTime = li.collecttime().data();
			p.strOpenContent = li.opencontent().data();

			p.doProcess(false);

			//qDebug() << "######### tLottery: strPeriods = " << p.strPeriods << ", strOpenContent = " << p.strOpenContent;
		}
		Q_EMIT setLotteryNext(p);
	}
	else if (msg.has_lotlatest())
	{
		tLottery p;
		{
			const pb::LotteryLatest& ll = msg.lotlatest();
			const pb::LotteryInfo& li = ll.lotinfo();

			p.strPeriods = li.periods().data();
			p.strBeginTime = li.begintime().data();
			p.strOpenTime = li.opentime().data();
			p.strCollectTime = li.collecttime().data();
			p.strOpenContent = li.opencontent().data();

			p.doProcess(true);

			//qDebug() << "######### tLottery: strPeriods = " << p.strPeriods << ", strOpenContent = " << p.strOpenContent;
		}
		Q_EMIT setLotteryLatest(p);
	}
}


