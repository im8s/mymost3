package com.shiku.commons.utils;

import com.mongodb.BasicDBObject;
import com.mongodb.DBObject;
import com.mongodb.client.FindIterable;
import com.mongodb.client.result.UpdateResult;
import org.bson.Document;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.util.StringUtils;

import com.mongodb.MongoClient;
import com.mongodb.client.MongoCollection;
import com.mongodb.client.MongoCursor;
import com.mongodb.client.MongoDatabase;

import java.util.regex.Pattern;

/**
* @Description: TODO(文件资源数据库操作工具 类)
* @author lidaye
* @date 2018年5月24日 
*/
public class ResourcesDBUtils {
	
	private static final Logger log = LoggerFactory.getLogger(ResourcesDBUtils.class);

	private static MongoCollection resourceCollection;
	
	private static MongoCollection delFilesCollection;
	
	static final String dbName="resources"; //库名

	static final String resources_collection_name = "resources"; //资源表名,主要用于记录上传的资源记录

	static final String delFile_collection_name = "del_files"; //文件删除表名，用于存放要删除的文件url，定时任务从该表读取数据，删除文件


	 public interface Expire {
			static final int DAY1 = 86400;
			static final int DAY7 = 604800;
			static final int HOUR12 = 43200;
			static final int HOUR=3600;
	 }

	 static{
		 String urIStr = ConfigUtils.getSystemConfig().getDbUri();
		 if( StringUtils.isEmpty(urIStr) ){
			 log.error("===> error msg dbUri is null =====>");
		 }
		 MongoClient mongoClient = MongoDBUtil.getMongoClient( urIStr );
		 
		 MongoDatabase db = mongoClient.getDatabase(dbName);

		 resourceCollection = db.getCollection(dbName);
	 }
	 
	 private static MongoCollection getResourceCollection(){
		 if(null!=resourceCollection)
			 return resourceCollection;
		 try {
			 String resourceUri = ConfigUtils.getSystemConfig().getDbUri();
			 if(StringUtils.isEmpty(resourceUri)){
				 log.error("===> error msg dbUri is null =====>");
			 }
			 MongoClient mongoClient=MongoDBUtil.getMongoClient(resourceUri);
			 
			 MongoDatabase db = mongoClient.getDatabase(dbName);

			 resourceCollection = db.getCollection(resources_collection_name);

			 return resourceCollection;

		} catch (Exception e) {
			e.printStackTrace();
			return resourceCollection;
		}

	 }


	private static MongoCollection getDelFilesCollection(){
		if( null!=delFilesCollection )
			return delFilesCollection;
		try {
			String delUri = ConfigUtils.getSystemConfig().getDelFileUri();
			if(StringUtils.isEmpty(delUri)){
				log.error("===> error msg dbUri is null =====>");
			}
			MongoClient mongoClient=MongoDBUtil.getMongoClient(delUri);

			MongoDatabase db = mongoClient.getDatabase(dbName);

			delFilesCollection = db.getCollection(delFile_collection_name);

			return delFilesCollection;

		} catch (Exception e) {
			e.printStackTrace();
			return delFilesCollection;
		}

	}

	//从 del collection 获取要删除的文件url，然后删除对应的文件
	public static void delFileFromDelCollection(){

		MongoCollection delCollection = getDelFilesCollection();

		MongoCursor<Document> iterator = delCollection.find().limit(1000).iterator();

		String fileUri = "";

		String fileChildPath = "";

		if(!iterator.hasNext())
			return;

		while (iterator.hasNext()) {
			Document result = iterator.next();
			if ( null == result )
				continue;
			try {

				fileUri = "" + result.getString("value");

				if(-1 != fileUri.indexOf(",")) //uri 可能有多个
					fileUri = fileUri.split(",")[0];

				if(fileUri.startsWith("http://")||fileUri.startsWith("https://")){
					String tempPath =  fileUri.substring( fileUri.indexOf("//")+2 );
					fileChildPath  = tempPath.substring( tempPath.indexOf("/") );
				}

				if(StringUtils.isEmpty(fileChildPath)) {
					delCollection.deleteOne(new Document("_id",result.getString("_id")));
					continue;
				}

				if( 1 == ConfigUtils.getSystemConfig().getIsOpenfastDFS() || fileChildPath.startsWith("group") )
					FastDFSUtils.deleteFile(fileChildPath);
				else {
					FileUtils.deleteFile(fileChildPath);
				}


			}catch (Exception e){
				log.error(e.getMessage());
			}

			delCollection.deleteOne(new Document("_id",result.getString("_id")));

			log.info("File "+ fileUri +" Already Delete");
		}

		//递归调用
		delFileFromDelCollection();

	}


	 
	 /**
	 * @Description: TODO(保存文件的 url 到数据库)
	 * @param @param type  1 本机文件系统  2 fastDfs
	 * @param @param path  文件的url
	 * @param @param validTime   文件的有效期   0/-1 为永久 有效期       1<validTime 有效期 多少天
	  */
	 public static void saveFileUrl(int type,String url,double validTime){
		 long cuTime=System.currentTimeMillis()/1000;
		 long endTime=-1;
		 
		 if(validTime>0)
				endTime=cuTime+(long)(Expire.DAY1* validTime);
		 else endTime=-1;
		 
		/**
		 * 获取文件的真实地址  不带 域名
		 */
		String path=FileUtils.getAbsolutePath(url);
		String fileName= FileUtils.getFileName(path);
		if(1==type) {
			path=ConfigUtils.getBasePath()+"/"+path;
		}
		
		 Document document=new Document("createTime", cuTime);
		 
		 
		 document.append("endTime", endTime);
		 document.append("url", url);
		 document.append("path", path);
		 document.append("type", type);
		 document.append("status", 1);
		 document.append("fileName",fileName);
		 document.append("citations", 1);

		 getResourceCollection().insertOne(document);
		 
	 }
	 
	 /**
	 * @Description: TODO(删除数据库的文件)
	 * @param @param path  文件的path
	  */
	 public static void deleteFile(String path){
		
		 
		 Document query=new Document("path", path);


		 getResourceCollection().deleteOne(query);
		 
	 }
	 
	 /**
	 * @Description: TODO(修改文件的状态  )
	 * @param @param path  文件的url
	 * 
	  */
	 public static void updateFileStatus(String path,int status){
		
		 
		 Document query=new Document("url", path);
		
		 Document values=new Document("status", path);

		 getResourceCollection().updateOne(query, new Document("$set", values));
		 
	 }



	 
	 public static void runDeleteFileTask(){
		
		 long cuTime=System.currentTimeMillis()/1000;
		 Document query=new Document("endTime", new Document("$gt", 0).append("$lt", cuTime));
		 MongoCollection collection = getResourceCollection();
		 long count = collection.count(query);
		 MongoCursor<Document> cursor= collection.find(query).iterator();
		 Document resultDoc=null;
		 String path=null;
		 String url="";
		 int type=1;
		 log.info(" runDeleteFileTask query count {} ",count);
		 while (cursor.hasNext()) {
				resultDoc=cursor.next();
				if(null==resultDoc)
					continue;
				log.info(" run delete task {} ",resultDoc);
				path=resultDoc.getString("path");
				 type = resultDoc.getInteger("type");
				if(StringUtils.isEmpty(path))
					path=resultDoc.getString("url");
				if(StringUtils.isEmpty(path))
					continue;
				if(2==type)
					FastDFSUtils.deleteFile(path);
				else {
					FileUtils.deleteFile(path);
				}
			}
		 getResourceCollection().deleteMany(query);
	}
	/**
	 * 根据文件名修改文件引用次数
	 * @param fileName 文件名
	 * @param citations 引用次数
	 * @return
	 */
	public static UpdateResult updateFileCitations(String fileName, int citations){
		BasicDBObject query = new BasicDBObject();
		query.put("fileName", fileName);
		return  getResourceCollection().updateMany(query, new BasicDBObject("$inc", new BasicDBObject("citations", citations)));
	}

	/**
	 * 根据文件名查找数据
	 * @param fileName
	 * @return
	 */
	public static FindIterable<Document> findFileByFileName(String fileName){
		BasicDBObject query = new BasicDBObject();
		query.put("fileName", fileName);
		return  getResourceCollection().find(query);
	}

	/**
	 * @Description: TODO(删除数据库的文件)
	 * @param @param path  文件的path
	 */
	public static void deleteFileByFileName(String fileName){

		Document query=new Document("fileName", fileName);

		getResourceCollection().deleteMany(query);

	}

}

