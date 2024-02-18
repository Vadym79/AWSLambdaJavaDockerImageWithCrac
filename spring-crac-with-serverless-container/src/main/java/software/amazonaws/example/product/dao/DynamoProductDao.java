// Copyright Amazon.com, Inc. or its affiliates. All Rights Reserved.
// SPDX-License-Identifier: MIT-0

package software.amazonaws.example.product.dao;

import java.net.URI;
import java.util.ArrayList;
import java.util.List;
import java.util.Map;
import java.util.Optional;
import java.time.Duration;

import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.stereotype.Repository;

import software.amazon.awssdk.auth.credentials.DefaultCredentialsProvider;
import software.amazon.awssdk.core.client.config.ClientOverrideConfiguration;
import software.amazon.awssdk.http.urlconnection.UrlConnectionHttpClient;
import software.amazon.awssdk.regions.Region;
import software.amazon.awssdk.services.dynamodb.DynamoDbClient;
import software.amazon.awssdk.services.dynamodb.model.AttributeValue;
import software.amazon.awssdk.services.dynamodb.model.DeleteItemRequest;
import software.amazon.awssdk.services.dynamodb.model.GetItemRequest;
import software.amazon.awssdk.services.dynamodb.model.GetItemResponse;
import software.amazon.awssdk.services.dynamodb.model.PutItemRequest;
import software.amazon.awssdk.services.dynamodb.model.ScanRequest;
import software.amazon.awssdk.services.dynamodb.model.ScanResponse;
import software.amazonaws.example.product.entity.Product;
import software.amazonaws.example.product.entity.Products;
import software.amazon.awssdk.http.SdkHttpClient;
import software.amazon.awssdk.http.apache.ApacheHttpClient;

  
@Repository
public class DynamoProductDao implements ProductDao {
  private static final Logger logger = LoggerFactory.getLogger(DynamoProductDao.class);
  private static final String PRODUCT_TABLE_NAME = System.getenv("PRODUCT_TABLE_NAME");
  private static final String ENDPOINT = System.getenv("AWS_ENDPOINT_URL_DYNAMODB");

  private static final SdkHttpClient httpClientForPriming = ApacheHttpClient.builder().
		  connectionTimeToLive(Duration.ofSeconds(1)).
		  socketTimeout(Duration.ofSeconds(1)).
		  connectionTimeout(Duration.ofSeconds(1)).
		  build();
  
  private static final SdkHttpClient httpClient = ApacheHttpClient.builder().
		  build();
  
  private static final DynamoDbClient dynamoDbClientforPriming = getDynamoDbClient(httpClientForPriming, true);
  private static final DynamoDbClient dynamoDbClient = getDynamoDbClient(httpClient,true);
  
  private static DynamoDbClient getDynamoDbClient (SdkHttpClient httpClient, boolean setEndPoint) {
		if (ENDPOINT != null && setEndPoint) {
			return DynamoDbClient.builder().endpointOverride(URI.create(ENDPOINT))
					.credentialsProvider(DefaultCredentialsProvider.create())
					.region(Region.EU_CENTRAL_1)
					.httpClient(httpClient)
					.overrideConfiguration(ClientOverrideConfiguration.builder().build())
					.httpClient(httpClient).build();
		} else {
			return DynamoDbClient.builder()
			     .credentialsProvider(DefaultCredentialsProvider.create())
					.region(Region.EU_CENTRAL_1).httpClient(httpClient)
					.overrideConfiguration(ClientOverrideConfiguration.builder().build())
					.httpClient(httpClient).build();
		}
	}  

  @Override
  public void closeForPriming () {
    httpClientForPriming.close();
    //dynamoDbClientforPriming.close();
  }
  
  @Override
  public Optional<Product> getProductForPriming(String id) {
      return this.getProduct(id, dynamoDbClientforPriming);
  }
  
  @Override
  public Optional<Product> getProduct(String id) {
      DynamoDbClient dynamoDbLocalClient = getDynamoDbClient(httpClient, true);
      return  this.getProduct(id, dynamoDbLocalClient);
  }
  
  
  private Optional<Product> getProduct(String id, DynamoDbClient dynamoDbLocalClient) {
    logger.info ("product table name "+PRODUCT_TABLE_NAME);
    logger.info ("endpoint "+ENDPOINT);
    GetItemResponse getItemResponse = dynamoDbLocalClient.getItem(GetItemRequest.builder()
      .key(Map.of("PK", AttributeValue.builder().s(id).build()))
      .tableName(PRODUCT_TABLE_NAME)
      .build());
    if (getItemResponse.hasItem()) {
       logger.info ("has items ");
      return Optional.of(ProductMapper.productFromDynamoDB(getItemResponse.item()));
    } else {
      logger.info ("end get item ");
      return Optional.empty();
    }
    
  }

  @Override
  public void putProduct(Product product) {
    dynamoDbClient.putItem(PutItemRequest.builder()
      .tableName(PRODUCT_TABLE_NAME)
      .item(ProductMapper.productToDynamoDb(product))
      .build());
  }

  @Override
  public void deleteProduct(String id) {
    dynamoDbClient.deleteItem(DeleteItemRequest.builder()
      .tableName(PRODUCT_TABLE_NAME)
      .key(Map.of("PK", AttributeValue.builder().s(id).build()))
      .build());
  }

  @Override
  public Products getAllProduct() {
    ScanResponse scanResponse = dynamoDbClient.scan(ScanRequest.builder()
      .tableName(PRODUCT_TABLE_NAME)
      .limit(20)
      .build());

    logger.info("Scan returned: {} item(s)", scanResponse.count());

    List<Product> productList = new ArrayList<>();

    for (Map<String, AttributeValue> item : scanResponse.items()) {
      productList.add(ProductMapper.productFromDynamoDB(item));
    }
    return new Products(productList);
  }
}
