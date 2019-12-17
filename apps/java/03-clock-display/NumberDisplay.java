
/**
 * Write a description of class NumberDisplay here.
 *
 * @author (your name)
 * @version (a version number or a date)
 */
public class NumberDisplay
{
    // instance variables - replace the example below with your own
    private int limit;
    private int value;

/**
 * contructor class for NumberDisplay
 * limit for objects 'hours' and 'minutes' set here
 */
public NumberDisplay(int rollOverLimit)
{
 limit = rollOverLimit;
 value = 0;
}

/**
 * get value on dial
 */
public int getValue(int Value)
{
    return(value);
}

/**
 * set the values of the display
 */

public void setValue(int replacementValue)
{
    if ((replacementValue >= 0) &&
            (replacementValue < limit)) {
                value = replacementValue;
    }

}

/** 
 * return the display values
 */

public String getDisplay()
{
    if(value < 10){
        return "0" + value;
    } 
    else {
        return "" + value;
    }
    
}

/**
 * increment the values
 */

public void increment()
{
    value = (value + 1) % limit;

}

}
