package software.amazonaws;

import java.util.Optional;

import org.crac.Context;
import org.crac.Core;
import org.crac.Resource;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.context.annotation.Configuration;
import software.amazonaws.example.product.dao.DynamoProductDao;
import software.amazonaws.example.product.entity.Product;

import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import java.nio.file.*;

@Configuration
public class PrimingResource implements Resource {

	@Autowired
	private DynamoProductDao productDao;

	private static final Logger logger = LoggerFactory.getLogger(PrimingResource.class);

	public PrimingResource() {
		Core.getGlobalContext().register(this);
	}

	@Override
	public void beforeCheckpoint(Context<? extends Resource> context) throws Exception {
		logger.info("beforeCheckpoint hook");
		// Below line would initialize the AWS SDK DynamoDBClient class. This technique
		// is called "Priming".

		Optional<Product> optionalProduct = productDao.getProductForPriming("0");
		if (optionalProduct.isPresent())
			logger.info(" product : " + optionalProduct.get());
		else
			logger.info(" product not found ");

		productDao.closeForPriming();
		logger.info(" closed client ");
		Thread.sleep(1500);
	}

	@Override
	public void afterRestore(Context<? extends Resource> context) throws Exception {
		System.out.println("afterRestore hook");
		String content = new String(Files.readAllBytes(Paths.get("/tmp/crac/dump4.log")));
        logger.info(content);
	}
}