import java.util.ArrayList;
import java.util.List;
import java.util.UUID;
import java.util.concurrent.locks.ReentrantLock;

public class ReentrantLockMain {

    public static void main(String[] args) {
        DataHolder dataHolder = DataHolder.getInstance();

        int f = 10000; // nb uuids
        System.out.println("Generating " + f + " uuids");
        for (int i=0; i < f; i++) {
            dataHolder.addDeclaredData(UUID.randomUUID().toString());
        }

        int t = 10; // nb threads
        for (int j=0; j < t; j++) {
            DataManipulator dataManipulator = new DataManipulator(dataHolder);
            Thread thread = new Thread(dataManipulator);
            thread.start();
        }
    }

    /**
     * Data holder container 2 List, origin and destination
     */
    public static class DataHolder {

        private static final DataHolder instance;

        private ReentrantLock lock = new ReentrantLock();

        private List<String> origin = new ArrayList<>();
        private List<String> destination = new ArrayList<>();

        static {
            instance = new DataHolder();
        }

        public static DataHolder getInstance() {
            return instance;
        }

        public void addDeclaredData(String data) {
            lock.lock();
            try {
                origin.add(data);
            } finally {
                lock.unlock();
            }
        }

        /**
         * mode data between origin and destination, n items at a time
         * activates lock to secure the 'transaction' between origin and destination
         *
         * @return true if move occured
         */
        public boolean moveData() {
            // uncomment and see
            lock.lock();
            try {
                // if declared is empty then we did not move any data
                if (origin.size() == 0) {
                    return false;
                } else {

                    // move data
                    int moveElementsAtATime = (int) (Math.random() * 100) + 1;
                    int i = origin.size() <= moveElementsAtATime ? origin.size() : moveElementsAtATime;
                    List<String> listToTransfer = origin.subList(0, i);

                    destination.addAll(listToTransfer);
                    origin.removeAll(listToTransfer);

                    System.out.println("Thread " + Thread.currentThread().getId() + " moving " + i + " elements. Origin: " + origin.size() + " > " + destination.size());

                    return true;
                }
            } finally {
                // uncomment and see
                lock.unlock();
            }
        }
    }

    /**
     * Runnable data manipulator. Calls moveData() on data holder as a thread
     */

    public static class DataManipulator implements Runnable {

        private DataHolder dataHolder;

        public DataManipulator(DataHolder dataHolder) {
            this.dataHolder = dataHolder;
        }

        @Override
        public void run() {
            boolean dataMoved = true;
            while (dataMoved) {
                dataMoved = dataHolder.moveData();
            }
        }
    }
}
