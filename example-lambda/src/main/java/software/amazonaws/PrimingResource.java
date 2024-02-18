package software.amazonaws;

import org.crac.Context;
import org.crac.Core;
import org.crac.Resource;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.context.annotation.Configuration;
import software.amazonaws.example.product.dao.DynamoProductDao;
import software.amazonaws.example.product.entity.Product;

@Configuration
public class PrimingResource implements Resource {

  @Autowired
  private DynamoProductDao productDao;

  public PrimingResource() {
    Core.getGlobalContext().register(this);
  }

  @Override
  public void beforeCheckpoint(Context<? extends Resource> context) throws Exception {
    System.out.println("beforeCheckpoint hook");
    //Below line would initialize the AWS SDK DynamoDBClient class. This technique is called "Priming".
    //productDao.getProduct("0");
  }

  @Override
  public void afterRestore(Context<? extends Resource> context) throws Exception {
    System.out.println("afterRestore hook");
  }
}