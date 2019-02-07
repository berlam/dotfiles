import static org.junit.Assert.*;
import org.junit.Rule;
import org.junit.rules.ExpectedException;
import org.junit.runner.RunWith;
import org.springframework.test.context.junit4.SpringJUnit4ClassRunner;

@RunWith(SpringJUnit4ClassRunner.class)
public class ${NAME} {

  @Rule
  public ExpectedException exception = ExpectedException.none();

  private final ${CLASS_NAME} uut;

  public ${NAME}() {
    this.uut = new ${CLASS_NAME}();
  }

  ${BODY}
}