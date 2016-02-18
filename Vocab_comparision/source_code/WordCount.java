
import java.io.BufferedReader;
import java.io.File;
import java.io.FileReader;
import java.net.URI;
import java.util.HashSet;
import java.util.Set;
import java.io.IOException;
import java.util.regex.Pattern;
import org.apache.hadoop.conf.Configuration;
import org.apache.hadoop.conf.Configured;
import org.apache.hadoop.util.Tool;
import org.apache.hadoop.util.ToolRunner;
import org.apache.hadoop.mapreduce.Job;
import org.apache.hadoop.mapreduce.Mapper;
import org.apache.hadoop.mapreduce.Reducer;
import org.apache.hadoop.fs.Path;
import org.apache.hadoop.mapreduce.lib.input.FileInputFormat;
import org.apache.hadoop.mapreduce.lib.input.FileSplit;
import org.apache.hadoop.mapreduce.lib.output.FileOutputFormat;
import org.apache.hadoop.io.IntWritable;
import org.apache.hadoop.io.LongWritable;
import org.apache.hadoop.io.Text;
import org.apache.hadoop.util.StringUtils;

import org.apache.log4j.Logger;

public class WordCount extends Configured implements Tool {

  private static final Logger LOG = Logger.getLogger(WordCount.class);

  public static void main(String[] args) throws Exception {
    int res = ToolRunner.run(new WordCount(), args);
    System.exit(res);
  }

  public int run(String[] args) throws Exception {
    Job job = Job.getInstance(getConf(), "wordcount");
    for (int i = 0; i < args.length; i += 1) {
      if ("-skip".equals(args[i])) {
        job.getConfiguration().setBoolean("wordcount.skip.patterns", true);
        i += 1;
        job.addCacheFile(new Path(args[i]).toUri());
        LOG.info("Added file to the distributed cache: " + args[i]);
      }
    }
    job.setJarByClass(this.getClass());
    FileInputFormat.addInputPath(job, new Path(args[0]));
    FileOutputFormat.setOutputPath(job, new Path(args[1]));
    job.setMapperClass(Map.class);
    job.setCombinerClass(Reduce.class);
    job.setReducerClass(Reduce.class);
    job.setOutputKeyClass(Text.class);
    job.setOutputValueClass(IntWritable.class);
    return job.waitForCompletion(true) ? 0 : 1;
  }
  public static class PorterStemmer
	{	  
	private char[] b;
   private int i,     
               i_end, 
               j, k;
   private static final int INC = 50;
                     
   public PorterStemmer()
   {  b = new char[INC];
      i = 0;
      i_end = 0;
   }

   

   public void add(char ch)
   {  if (i == b.length)
      {  char[] new_b = new char[i+INC];
         for (int c = 0; c < i; c++) new_b[c] = b[c];
         b = new_b;
      }
      b[i++] = ch;
   }



   public void add(char[] w, int wLen)
   {  if (i+wLen >= b.length)
      {  char[] new_b = new char[i+wLen+INC];
         for (int c = 0; c < i; c++) new_b[c] = b[c];
         b = new_b;
      }
      for (int c = 0; c < wLen; c++) b[i++] = w[c];
   }

   public String toString() { return new String(b,0,i_end); }

   
   public int getResultLength() { return i_end; }

   public char[] getResultBuffer() { return b; }


   private final boolean cons(int i)
   {  switch (b[i])
      {  case 'a': case 'e': case 'i': case 'o': case 'u': return false;
         case 'y': return (i==0) ? true : !cons(i-1);
         default: return true;
      }
   }

   

   private final int m()
   {  int n = 0;
      int i = 0;
      while(true)
      {  if (i > j) return n;
         if (! cons(i)) break; i++;
      }
      i++;
      while(true)
      {  while(true)
         {  if (i > j) return n;
               if (cons(i)) break;
               i++;
         }
         i++;
         n++;
         while(true)
         {  if (i > j) return n;
            if (! cons(i)) break;
            i++;
         }
         i++;
       }
   }

  

   private final boolean vowelinstem()
   {  int i; for (i = 0; i <= j; i++) if (! cons(i)) return true;
      return false;
   }

 

   private final boolean doublec(int j)
   {  if (j < 1) return false;
      if (b[j] != b[j-1]) return false;
      return cons(j);
   }

   

   private final boolean cvc(int i)
   {  if (i < 2 || !cons(i) || cons(i-1) || !cons(i-2)) return false;
      {  int ch = b[i];
         if (ch == 'w' || ch == 'x' || ch == 'y') return false;
      }
      return true;
   }

   private final boolean ends(String s)
   {  int l = s.length();
      int o = k-l+1;
      if (o < 0) return false;
      for (int i = 0; i < l; i++) if (b[o+i] != s.charAt(i)) return false;
      j = k-l;
      return true;
   }

  

   private final void setto(String s)
   {  int l = s.length();
      int o = j+1;
      for (int i = 0; i < l; i++) b[o+i] = s.charAt(i);
      k = j+l;
   }

  

   private final void r(String s) { if (m() > 0) setto(s); }

  

   private final void step1()
   {  if (b[k] == 's')
      {  if (ends("sses")) k -= 2; else
         if (ends("ies")) setto("i"); else
         if (b[k-1] != 's') k--;
      }
}
      /*if (ends("eed")) { if (m() > 0) k--; } else
      if ((ends("ed") || ends("ing")) && vowelinstem())
      {  k = j;
         if (ends("at")) setto("ate"); else
         if (ends("bl")) setto("ble"); else
         if (ends("iz")) setto("ize"); else
         if (doublec(k))
         {  k--;
            {  int ch = b[k];
               if (ch == 'l' || ch == 's' || ch == 'z') k++;
            }
         }
         else if (m() == 1 && cvc(k)) setto("e");
     }
   }*/

  
  // private final void step2() { if (ends("y") && vowelinstem()) b[k] = 'i'; }

   

   //private final void step3() { if (k == 0) return; /* For Bug 1 */ switch (b[k-1])
   /*{
       case 'a': if (ends("ational")) { r("ate"); break; }
                 if (ends("tional")) { r("tion"); break; }
                 break;
       case 'c': if (ends("enci")) { r("ence"); break; }
                 if (ends("anci")) { r("ance"); break; }
                 break;
       case 'e': if (ends("izer")) { r("ize"); break; }
                 break;
       case 'l': if (ends("bli")) { r("ble"); break; }
                 if (ends("alli")) { r("al"); break; }
                 if (ends("entli")) { r("ent"); break; }
                 if (ends("eli")) { r("e"); break; }
                 if (ends("ousli")) { r("ous"); break; }
                 break;
       case 'o': if (ends("ization")) { r("ize"); break; }
                 if (ends("ation")) { r("ate"); break; }
                 if (ends("ator")) { r("ate"); break; }
                 break;
       case 's': if (ends("alism")) { r("al"); break; }
                 if (ends("iveness")) { r("ive"); break; }
                 if (ends("fulness")) { r("ful"); break; }
                 if (ends("ousness")) { r("ous"); break; }
                 break;
       case 't': if (ends("aliti")) { r("al"); break; }
                 if (ends("iviti")) { r("ive"); break; }
                 if (ends("biliti")) { r("ble"); break; }
                 break;
       case 'g': if (ends("logi")) { r("log"); break; }
   } }*/

   
  /* private final void step4() { switch (b[k])
   {
       case 'e': if (ends("icate")) { r("ic"); break; }
                 if (ends("ative")) { r(""); break; }
                 if (ends("alize")) { r("al"); break; }
                 break;
       case 'i': if (ends("iciti")) { r("ic"); break; }
                 break;
       case 'l': if (ends("ical")) { r("ic"); break; }
                 if (ends("ful")) { r(""); break; }
                 break;
       case 's': if (ends("ness")) { r(""); break; }
                 break;
   } }*/



   //private final void step5()
  // {   if (k == 0) return; /* for Bug 1 */ switch (b[k-1])
     /*  {  case 'a': if (ends("al")) break; return;
          case 'c': if (ends("ance")) break;
                    if (ends("ence")) break; return;
          case 'e': if (ends("er")) break; return;
          case 'i': if (ends("ic")) break; return;
          case 'l': if (ends("able")) break;
                    if (ends("ible")) break; return;
          case 'n': if (ends("ant")) break;
                    if (ends("ement")) break;
                    if (ends("ment")) break;
                    /* element etc. not stripped before the m */
                   /* if (ends("ent")) break; return;
          case 'o': if (ends("ion") && j >= 0 && (b[j] == 's' || b[j] == 't')) break;
                                    /* j >= 0 fixes Bug 2 */
                   // if (ends("ou")) break; return;
                    /* takes care of -ous */
         /* case 's': if (ends("ism")) break; return;
          case 't': if (ends("ate")) break;
                    if (ends("iti")) break; return;
          case 'u': if (ends("ous")) break; return;
          case 'v': if (ends("ive")) break; return;
          case 'z': if (ends("ize")) break; return;
          default: return;
       }
       if (m() > 1) k = j;
   }*/

 
   /*private final void step6()
   {  j = k;
      if (b[k] == 'e')
      {  int a = m();
         if (a > 1 || a == 1 && !cvc(k-1)) k--;
      }
      if (b[k] == 'l' && doublec(k) && m() > 1) k--;
   }*/

   public void stem()
   {  k = i - 1;
      if (k > 1) { step1(); }
      i_end = k+1; i = 0;
   }
   }
  public static class Map extends Mapper<LongWritable, Text, Text, IntWritable> {
    private final static IntWritable one = new IntWritable(1);
    private Text word = new Text();
    private boolean caseSensitive = false;
    private long numRecords = 0;
    private String input;
    private Set<String> skiplist = new HashSet<String>();
    private static final Pattern filter = Pattern.compile("[^A-Za-z0-9]");

    protected void setup(Mapper.Context context)
        throws IOException,
        InterruptedException {
      if (context.getInputSplit() instanceof FileSplit) {
        this.input = ((FileSplit) context.getInputSplit()).getPath().toString();
      } else {
        this.input = context.getInputSplit().toString();
      }
      Configuration config = context.getConfiguration();
      this.caseSensitive = config.getBoolean("wordcount.case.sensitive", false);
      if (config.getBoolean("wordcount.skip.patterns", false)) {
        URI[] localPaths = context.getCacheFiles();
        parseSkipFile(localPaths[0]);
      }
    }

    private void parseSkipFile(URI patternsURI) {
      LOG.info("Added file to the distributed cache: " + patternsURI);
      try {
        BufferedReader fis = new BufferedReader(new FileReader(new File(patternsURI.getPath()).getName()));
        String pattern;
        while ((pattern = fis.readLine()) != null) {
          skiplist.add(pattern);
        }
      } catch (IOException ioe) {
        System.err.println("Caught exception while parsing the cached file '"
            + patternsURI + "' : " + StringUtils.stringifyException(ioe));
      }
    }

    public void map(LongWritable offset, Text lineText, Context context)
        throws IOException, InterruptedException {
      String line = lineText.toString();
      if (!caseSensitive) {
        line = line.toLowerCase();
      }
      Text currentWord = new Text();

      for (String word : filter.split(line)) {
        if (word.isEmpty() || skiplist.contains(word)) {
            continue;
        }
        if (Character.isDigit(word.charAt(0)) || !Character.isLetter(word.charAt(0))||word.length()<3) {
		continue;
	}
            PorterStemmer s = new PorterStemmer();
                for (int c = 0; c < word.length(); c++) s.add(word.charAt(c));
                s.stem();
                String pattern;
                pattern = s.toString();
	    if (pattern.isEmpty() || skiplist.contains(pattern)) 
            continue;
        
	     currentWord = new Text(pattern);
            context.write(currentWord,one);

        }             
    }
  }

  public static class Reduce extends Reducer<Text, IntWritable, Text, IntWritable> {
    @Override
    public void reduce(Text word, Iterable<IntWritable> counts, Context context)
        throws IOException, InterruptedException {
      int sum = 0;
      for (IntWritable count : counts) {
        sum += count.get();
      }
      context.write(word, new IntWritable(sum));
    }
  }
}
